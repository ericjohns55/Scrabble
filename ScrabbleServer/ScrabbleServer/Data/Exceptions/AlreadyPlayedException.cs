namespace ScrabbleServer.Data.Exceptions;

public class AlreadyPlayedException : Exception
{
    public AlreadyPlayedException(string message) : base(message) { }
}