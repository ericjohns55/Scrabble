namespace ScrabbleServer.Data.Models.DTOs;

public class GameMoveDTO
{
    public long Id { get; init; }
    
    public long PlayerId { get; init; }

    public long GameId { get; init; }

    public DateTime SentAt { get; init; }

    public int Score { get; init; }

    public int WordsPlayed { get; init; }
    
    public int TilesPlayed { get; init; }
    
    public int MovesMade { get; init; }

    public string SerializedBoard { get; set; } = string.Empty;
}