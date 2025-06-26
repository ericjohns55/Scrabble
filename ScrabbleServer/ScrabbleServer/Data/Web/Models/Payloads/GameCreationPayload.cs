using ScrabbleServer.Data.Models.Types;

namespace ScrabbleServer.Data.Web.Models.Payloads;

public class GameCreationPayload
{
    public BoardIdentifier BoardIdentifier { get; init; }
    
    public long Seed { get; init; }
    
    public Guid OpponentUuid { get; init; }
}