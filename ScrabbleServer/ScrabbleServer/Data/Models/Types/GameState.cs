namespace ScrabbleServer.Data.Models.Types;

public enum GameState
{
    Pending,
    Declined,
    WaitingForMoves,
    Completed,
    Forfeited
}