using ScrabbleServer.Data.Models.Types;

namespace ScrabbleServer.Data.Models.DTOs;

public class GameDTO
{
    public long Id { get; init; }
    
    public Guid Uuid { get; init; }
    
    public long Seed { get; init; }
    
    public DateTime CreatedAt { get; init; }
    
    public DateTime? CompletedAt { get; init; }

    public DateTime UpdatedAt { get; init; }

    public BoardIdentifier BoardIdentifier { get; init; }
    
    public GameState GameState { get; set; }
    
    public PlayerDTO InitiatingPlayer { get; init; }
    
    public PlayerDTO OpposingPlayer { get; init; }

    public GameMoveDTO? InitiatingPlayerMove { get; set; }

    public GameMoveDTO? OpposingPlayerMove { get; set; }

    public PlayerDTO? WinningPlayer { get; set; } = null;

    public bool? GameTied { get; set; } = null;
}