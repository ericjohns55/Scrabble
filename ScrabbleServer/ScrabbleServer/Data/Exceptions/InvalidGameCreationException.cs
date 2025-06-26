namespace ScrabbleServer.Data.Exceptions;

public class InvalidGameCreationException : Exception
{
    public InvalidGameCreationException(string message) : base(message) { }
}