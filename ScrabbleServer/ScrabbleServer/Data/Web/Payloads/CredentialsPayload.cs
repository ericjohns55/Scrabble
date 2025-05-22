namespace ScrabbleServer.Data.Web.Payloads;

public class CredentialsPayload
{
    public string Username { get; init; } = string.Empty;
    
    public string Password { get; init; } = string.Empty;
}