namespace ScrabbleServer.Data.Models.Types;

public enum GameState
{
    Pending,
    Denied,
    WaitingForMoves,
    Completed
}