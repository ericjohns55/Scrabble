namespace ScrabbleServer.Data.Exceptions;

public class DisplayNameTakenException : Exception
{
    public DisplayNameTakenException(string message) : base(message) { }
}