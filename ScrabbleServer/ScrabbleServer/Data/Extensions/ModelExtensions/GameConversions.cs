using ScrabbleServer.Data.Models.DatabaseModels;
using ScrabbleServer.Data.Models.DTOs;

namespace ScrabbleServer.Data.Extensions.ModelExtensions;

public static class GameConversions
{
    public static GameDTO ToDTO(this Game game)
    {
        var gameDto = new GameDTO()
        {
            Id = game.Id,
            Uuid = game.Uuid,
            Seed = game.Seed,
            CreatedAt = game.CreatedAt,
            CompletedAt = game.CompletedAt,
            BoardIdentifier = game.BoardIdentifier,
            GameState = game.GameState,
            InitiatingPlayer = game.InitiatingPlayer.ToDTO(),
            OpposingPlayer = game.OpposingPlayer.ToDTO(),
            InitiatingPlayerMove = game.InitiatingPlayerMove?.ToDTO() ?? null,
            OpposingPlayerMove = game.OpposingPlayerMove?.ToDTO() ?? null,
        };

        PlayerDTO? winningPlayer = null;
        if (game.WinningPlayerId != -1)
        {
            winningPlayer = gameDto.InitiatingPlayer.Id == game.WinningPlayerId
                ? gameDto.InitiatingPlayer
                : gameDto.OpposingPlayer;
        }
        
        gameDto.WinningPlayer = winningPlayer;
        
        return gameDto;
    }
}