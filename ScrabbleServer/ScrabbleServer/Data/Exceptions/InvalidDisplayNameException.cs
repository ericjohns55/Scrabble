namespace ScrabbleServer.Data.Exceptions;

public class InvalidDisplayNameException : Exception
{
    public InvalidDisplayNameException(string message) : base(message) { }
}