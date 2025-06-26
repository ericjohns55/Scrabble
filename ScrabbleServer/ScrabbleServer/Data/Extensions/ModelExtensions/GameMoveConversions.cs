using ScrabbleServer.Data.Models.DatabaseModels;
using ScrabbleServer.Data.Models.DTOs;

namespace ScrabbleServer.Data.Extensions.ModelExtensions;

public static class GameMoveConversions
{
    public static GameMoveDTO ToDTO(this GameMove gameMove)
    {
        return new GameMoveDTO()
        {
            Id = gameMove.Id,
            PlayerId = gameMove.PlayerId,
            GameId = gameMove.GameId,
            SentAt = gameMove.SentAt,
            Score = gameMove.Score,
            WordsPlayed = gameMove.WordsPlayed,
            TilesPlayed = gameMove.TilesPlayed,
            MovesMade = gameMove.MovesMade,
            SerializedBoard = gameMove.SerializedBoard
        };
    }
}