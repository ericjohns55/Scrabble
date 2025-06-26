using Microsoft.EntityFrameworkCore;
using ScrabbleServer.Data;
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

    public async Task<List<GameDTO>> GetGames(PlayerDTO currentPlayer, GameState? gameState = null)
    {
        var gamesQuery = _scrabbleContext.Games
            .Include(g => g.InitiatingPlayer)
            .Include(g => g.OpposingPlayer)
            .Include(g => g.InitiatingPlayerMove)
            .Include(g => g.OpposingPlayerMove)
            .Where(g => g.InitiatingPlayerId == currentPlayer.Id || g.OpposingPlayerId == currentPlayer.Id);

        if (gameState.HasValue)
        {
            gamesQuery = gamesQuery.Where(g => g.GameState == gameState.Value);
        }

        gamesQuery = gamesQuery.OrderByDescending(g => g.CreatedAt);
        
        return await gamesQuery.Select(g => g.ToDTO()).ToListAsync();
    }

    public async Task<Game> GetGame(Guid gameId)
    {
        var game = await _scrabbleContext.Games
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

    public async Task<GameDTO> CreateGame(PlayerDTO initiatingPlayer, GameCreationPayload creationPayload)
    {
        var opposingPlayer = await _playerService.GetPlayer(creationPayload.OpponentUuid);

        if (opposingPlayer.Id == initiatingPlayer.Id)
        {
            throw new InvalidGameCreationException("You cannot create a game with yourself");
        }

        var newGame = new Game()
        {
            InitiatingPlayerId = initiatingPlayer.Id,
            OpposingPlayerId = opposingPlayer.Id,
            Uuid = Guid.NewGuid(),
            BoardIdentifier = creationPayload.BoardIdentifier,
            Seed = creationPayload.Seed,
            CreatedAt = DateTime.UtcNow,
            GameState = GameState.Pending
        };
        
        await _scrabbleContext.Games.AddAsync(newGame);
        await _scrabbleContext.SaveChangesAsync();
        
        return (await GetGame(newGame.Uuid)).ToDTO();
    }

    public async Task<GameDTO> UpdateGame(Guid gameId, PlayerDTO currentPlayer, GameMovePayload gameMovePayload)
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
        
        await _scrabbleContext.GameMoves.AddAsync(newMove);
        await _scrabbleContext.SaveChangesAsync();

        if (isInitiator)
        {
            currentGame.InitiatingPlayerMoveId = newMove.Id;
        }
        else
        {
            currentGame.OpposingPlayerMoveId = newMove.Id;
        }

        await UpdateGameState(currentGame);

        _scrabbleContext.Update(currentGame);
        await _scrabbleContext.SaveChangesAsync();

        return await GetGameDto(currentGame.Uuid);
    }

    private async Task UpdateGameState(Game currentGame)
    {
        if (currentGame.OpposingPlayerMoveId != null && currentGame.InitiatingPlayerMoveId != null)
        {
            currentGame.GameState = GameState.Completed;
            currentGame.CompletedAt = DateTime.UtcNow;
            
            var initiatingPlayerMove = await GetGameMove(currentGame.InitiatingPlayerMoveId.Value);
            var opposingPlayerMove = await GetGameMove(currentGame.OpposingPlayerMoveId.Value);
            
            // TODO: handle ties
            
            var winningPlayerId = initiatingPlayerMove.Score > opposingPlayerMove.Score
                ? initiatingPlayerMove.PlayerId
                : opposingPlayerMove.PlayerId;
            
            currentGame.WinningPlayerId = winningPlayerId;
        }
        else
        {
            currentGame.GameState = GameState.WaitingForMoves;
        }
    }

    private Task<GameMove> GetGameMove(long gameMoveId)
    {
        return _scrabbleContext.GameMoves.SingleAsync(gm => gm.Id == gameMoveId);
    }
}