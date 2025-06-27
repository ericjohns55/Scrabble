namespace ScrabbleServer.Data.Exceptions;

public class GameException : Exception
{
    public GameException(string message) : base(message) { }
}