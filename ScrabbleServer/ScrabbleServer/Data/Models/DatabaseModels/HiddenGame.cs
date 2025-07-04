using System.ComponentModel.DataAnnotations.Schema;

namespace ScrabbleServer.Data.Models.DatabaseModels;

[Table("HIDDEN_GAME")]
public class HiddenGame
{
    [Column("ID")]
    public long Id { get; init; }

    [Column("GAME_ID")]
    public long GameId { get; init; }
    public Game Game { get; init; }
    
    [Column("PLAYER_ID")]
    public long PlayerId { get; init; }
    public Player Player { get; init; }
}