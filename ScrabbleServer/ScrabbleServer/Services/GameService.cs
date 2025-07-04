using Microsoft.EntityFrameworkCore;
using ScrabbleServer.Contexts;
using ScrabbleServer.Data.Exceptions;
using ScrabbleServer.Data.Extensions.ModelExtensions;
using ScrabbleServer.Data.Models.DatabaseModels;
using ScrabbleServer.Data.Models.DTOs;
using ScrabbleServer.Data.Models.Types;
using ScrabbleServer.Data.Web.Models.Payloads;

namespace ScrabbleServer.Services;

public class GameService
{
    private readonly ScrabbleContext _scrabbleContext;
    private readonly PlayerService _playerService;
    private readonly ILogger<GameService> _logger;

    public GameService(ScrabbleContext scrabbleContext, PlayerService playerService, ILogger<GameService> logger)
    {
        _scrabbleContext = scrabbleContext;
        _playerService = playerService;
        _logger = logger;
    }

    public async Task<List<GameDTO>> GetGames(Player currentPlayer, GameState? gameState = null)
    {
        var gamesQuery = _scrabbleContext.DatabaseContext.Games
            .Include(g => g.InitiatingPlayer)
            .Include(g => g.OpposingPlayer)
            .Include(g => g.InitiatingPlayerMove)
            .Include(g => g.OpposingPlayerMove)
            .Where(g => g.InitiatingPlayerId == currentPlayer.Id || g.OpposingPlayerId == currentPlayer.Id)
            .Where(g => !_scrabbleContext.DatabaseContext.HiddenGames
                .Any(hg => hg.GameId == g.Id && hg.PlayerId == currentPlayer.Id));

        if (gameState.HasValue)
        {
            gamesQuery = gamesQuery.Where(g => g.GameState == gameState.Value);
        }

        gamesQuery = gamesQuery.OrderByDescending(g => g.UpdatedAt);
        
        return await gamesQuery.Select(g => g.ToDTO()).ToListAsync();
    }

    public async Task<Game> GetGame(Guid gameId)
    {
        var game = await _scrabbleContext.DatabaseContext.Games
            .Include(g => g.InitiatingPlayer)
            .Include(g => g.OpposingPlayer)
            .Include(g => g.InitiatingPlayerMove)
            .Include(g => g.OpposingPlayerMove)
            .FirstOrDefaultAsync(g => g.Uuid == gameId);

        if (game == null)
        {
            throw new ItemNotFoundException($"Could not find game with ID {gameId}");
        }

        return game;
    }

    public async Task<GameDTO> GetGameDto(Guid gameId)
    {
        return (await GetGame(gameId)).ToDTO();
    }

    public async Task<GameDTO> CreateGame(Player initiatingPlayer, GameCreationPayload creationPayload)
    {
        var opposingPlayer = await _playerService.GetPlayer(creationPayload.OpponentUuid);

        if (opposingPlayer.Id == initiatingPlayer.Id)
        {
            throw new InvalidGameCreationException("You cannot create a game with yourself");
        }
        
        var currentTime = DateTime.UtcNow;

        var newGame = new Game()
        {
            InitiatingPlayerId = initiatingPlayer.Id,
            OpposingPlayerId = opposingPlayer.Id,
            Uuid = Guid.NewGuid(),
            BoardIdentifier = creationPayload.BoardIdentifier,
            Seed = creationPayload.Seed,
            CreatedAt = currentTime,
            UpdatedAt = currentTime,
            GameState = GameState.Pending
        };
        
        await _scrabbleContext.DatabaseContext.Games.AddAsync(newGame);
        await _scrabbleContext.DatabaseContext.SaveChangesAsync();
        
        return (await GetGame(newGame.Uuid)).ToDTO();
    }

    public async Task<GameDTO> DeclineGame(Player decliningPlayer, Guid gameId)
    {
        var game = await GetGame(gameId);

        if (game.GameState != GameState.Pending)
        {
            throw new GameException("You can only decline a game that has not started");
        }

        if (game.OpposingPlayerId != decliningPlayer.Id)
        {
            throw new GameException("You cannot decline a game you created");
        }
        
        var currentTime = DateTime.UtcNow;
        
        game.GameState = GameState.Declined;
        game.UpdatedAt = currentTime;
        game.CompletedAt = currentTime;
        
        _scrabbleContext.DatabaseContext.Update(game);
        await _scrabbleContext.DatabaseContext.SaveChangesAsync();
        
        return (await GetGame(gameId)).ToDTO();
    }

    public async Task<GameDTO> AcceptGame(Player acceptingPlayer, Guid gameId)
    {
        var game = await GetGame(gameId);

        if (game.GameState != GameState.Pending)
        {
            throw new GameException("You can only accept a game that has not started");
        }

        if (game.OpposingPlayerId != acceptingPlayer.Id)
        {
            throw new GameException("You cannot accept a game you created");
        }
        
        game.GameState = GameState.WaitingForMoves;
        game.UpdatedAt = DateTime.UtcNow;
        
        _scrabbleContext.DatabaseContext.Update(game);
        await _scrabbleContext.DatabaseContext.SaveChangesAsync();
        
        return (await GetGame(gameId)).ToDTO();
    }

    public async Task<GameDTO> ForfeitGame(Player forfeitingPlayer, Guid gameId)
    {
        var game = await GetGame(gameId);

        if (game.GameState == GameState.Pending && game.OpposingPlayerId == forfeitingPlayer.Id)
        {
            throw new GameException("You cannot forfeit a game you never accepted");
        }

        if (game.GameState != GameState.Pending && game.GameState != GameState.WaitingForMoves)
        {
            throw new GameException("This game can not be forfeited at this point");
        }
        
        if (game.OpposingPlayerId != forfeitingPlayer.Id && game.InitiatingPlayerId != forfeitingPlayer.Id)
        {
            throw new GameException("You are not part of this game");
        }

        var currentTime = DateTime.UtcNow;
        
        game.WinningPlayerId = game.OpposingPlayerId == forfeitingPlayer.Id ? game.InitiatingPlayerId : game.OpposingPlayerId;
        game.UpdatedAt = currentTime;
        game.CompletedAt = currentTime;
        game.GameState = GameState.Forfeited;
        
        _scrabbleContext.DatabaseContext.Update(game);
        await _scrabbleContext.DatabaseContext.SaveChangesAsync();
        
        return (await GetGame(gameId)).ToDTO();
    }

    public async Task<bool> HideGame(Player hidingPlayer, Guid gameId)
    {
        var game = await GetGame(gameId);

        if (_scrabbleContext.DatabaseContext.HiddenGames.Any(hg =>
                hg.PlayerId == hidingPlayer.Id && hg.GameId == game.Id))
        {
            throw new GameException("This game is already hidden");
        }

        var hiddenGame = new HiddenGame()
        {
            GameId = game.Id,
            PlayerId = hidingPlayer.Id
        };
        
        _scrabbleContext.DatabaseContext.HiddenGames.Add(hiddenGame);
        await _scrabbleContext.DatabaseContext.SaveChangesAsync();

        return true;
    }

    public async Task<GameDTO> UpdateGame(Guid gameId, Player currentPlayer, GameMovePayload gameMovePayload)
    {
        var currentGame = await GetGame(gameId);
        
        bool isOpponent = currentPlayer.Id == currentGame.OpposingPlayer.Id;
        bool isInitiator = currentPlayer.Id == currentGame.InitiatingPlayer.Id;
        long playerId;

        if (!isOpponent && !isInitiator)
        {
            throw new InvalidUserException("You are not part of this game");
        }

        if (isOpponent)
        {
            if (currentGame.OpposingPlayerMove == null)
            {
                playerId = currentGame.OpposingPlayer.Id;
            }
            else
            {
                throw new AlreadyPlayedException("You already played your turn");
            }
        }
        else
        {
            if (currentGame.InitiatingPlayerMove == null)
            {
                playerId = currentGame.InitiatingPlayer.Id;
            }
            else
            {
                throw new AlreadyPlayedException("You already played your turn");
            }
        }

        var newMove = new GameMove()
        {
            GameId = currentGame.Id,
            PlayerId = playerId,
            SentAt = DateTime.UtcNow,
            Score = gameMovePayload.Score,
            WordsPlayed = gameMovePayload.WordsPlayed,
            TilesPlayed = gameMovePayload.TilesPlayed,
            MovesMade = gameMovePayload.MovesMade,
            SerializedBoard = gameMovePayload.SerializedBoard
        };
        
        await _scrabbleContext.DatabaseContext.GameMoves.AddAsync(newMove);
        await _scrabbleContext.DatabaseContext.SaveChangesAsync();

        if (isInitiator)
        {
            currentGame.InitiatingPlayerMoveId = newMove.Id;
        }
        else
        {
            currentGame.OpposingPlayerMoveId = newMove.Id;
        }

        await UpdateGameState(currentGame);

        _scrabbleContext.DatabaseContext.Update(currentGame);
        await _scrabbleContext.DatabaseContext.SaveChangesAsync();

        return await GetGameDto(currentGame.Uuid);
    }

    private async Task UpdateGameState(Game currentGame)
    {
        var currentTime = DateTime.UtcNow;
        
        currentGame.UpdatedAt = DateTime.UtcNow;
        
        if (currentGame.OpposingPlayerMoveId != null && currentGame.InitiatingPlayerMoveId != null)
        {
            currentGame.GameState = GameState.Completed;
            currentGame.CompletedAt = currentTime;
            
            var initiatingPlayerMove = await GetGameMove(currentGame.InitiatingPlayerMoveId.Value);
            var opposingPlayerMove = await GetGameMove(currentGame.OpposingPlayerMoveId.Value);
            
            if (initiatingPlayerMove.Score == opposingPlayerMove.Score)
            {
                currentGame.WinningPlayerId = 0;
            }
            else
            {
                var winningPlayerId = initiatingPlayerMove.Score > opposingPlayerMove.Score
                    ? initiatingPlayerMove.PlayerId
                    : opposingPlayerMove.PlayerId;
            
                currentGame.WinningPlayerId = winningPlayerId;
            }
        }
        else
        {
            currentGame.GameState = GameState.WaitingForMoves;
        }
    }

    private Task<GameMove> GetGameMove(long gameMoveId)
    {
        return _scrabbleContext.DatabaseContext.GameMoves.SingleAsync(gm => gm.Id == gameMoveId);
    }
}