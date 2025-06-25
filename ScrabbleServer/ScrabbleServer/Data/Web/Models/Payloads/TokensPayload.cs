namespace ScrabbleServer.Data.Web.Models.Payloads;

public class TokensPayload
{
    public string AccessToken { get; init; }
    public string RefreshToken { get; init; }
}