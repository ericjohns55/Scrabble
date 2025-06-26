namespace ScrabbleServer.Data.Web.Models.Payloads;

public class GameMovePayload
{
    public int Score { get; init; }

    public int WordsPlayed { get; init; }
    
    public int TilesPlayed { get; init; }
    
    public int MovesMade { get; init; }

    public string SerializedBoard { get; set; } = string.Empty;
}