using System.ComponentModel.DataAnnotations.Schema;
using ScrabbleServer.Data.Models.Types;

namespace ScrabbleServer.Data.Models.DatabaseModels;

[Table("GAME")]
public class Game
{
    [Column("ID")]
    public long Id { get; init; }
    
    [Column("UUID")]
    public Guid Uuid { get; init; }
    
    [Column("SEED")]
    public long Seed { get; init; }
    
    [Column("CREATED_AT")]
    public DateTime CreatedAt { get; init; }
    
    [Column("UPDATED_AT")]
    public DateTime UpdatedAt { get; set; }
    
    [Column("COMPLETED_AT")]
    public DateTime? CompletedAt { get; set; }
    
    [Column("BOARD_IDENTIFIER")]
    public BoardIdentifier BoardIdentifier { get; init; }
    
    [Column("GAME_STATE")]
    public GameState GameState { get; set; }
    
    [Column("INITIATING_PLAYER_ID")]
    public long InitiatingPlayerId { get; init; }
    public Player InitiatingPlayer { get; init; }
    
    [Column("OPPOSING_PLAYER_ID")]
    public long OpposingPlayerId { get; init; }
    public Player OpposingPlayer { get; init; }

    [Column("INITIATING_PLAYER_GAME_MOVE")] 
    public long? InitiatingPlayerMoveId { get; set; }
    public GameMove? InitiatingPlayerMove { get; set; }

    [Column("OPPOSING_PLAYER_GAME_MOVE")] 
    public long? OpposingPlayerMoveId { get; set; }
    public GameMove? OpposingPlayerMove { get; set; }

    [Column("WINNING_PLAYER_ID")] 
    public long WinningPlayerId { get; set; } = -1;
}