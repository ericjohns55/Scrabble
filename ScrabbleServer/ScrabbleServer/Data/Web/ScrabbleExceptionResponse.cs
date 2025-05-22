namespace ScrabbleServer.Data.Web;

public class ScrabbleExceptionResponse
{
    public int StatusCode { get; init; }
    public string Identifier { get; init; }
    public string Route { get; init; }
    public string Message { get; init; }
    public string Details { get; init; }
}