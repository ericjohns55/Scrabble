using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ScrabbleServer.Data.Models.DatabaseModels;

[Table("GAME_MOVE")]
public class GameMove
{
    [Column("ID")]
    public long Id { get; init; }
    
    [Column("GAME_ID")]
    public long GameId { get; init; }
    public Game? Game { get; init; }
    
    [Column("PLAYER_ID")]
    public long PlayerId { get; init; }
    public Player? Player { get; init; }

    [Column("SENT_AT")]
    public DateTime SentAt { get; init; }

    [Column("SCORE")]
    public int Score { get; init; }

    [Column("WORDS_PLAYED")] 
    public int WordsPlayed { get; init; }
    
    [Column("TILES_PLAYED")]
    public int TilesPlayed { get; init; }
    
    [Column("MOVES_MADE")]
    public int MovesMade { get; init; }

    [MaxLength(4096)]
    [Column("SERIALIZED_BOARD")]
    public string SerializedBoard { get; set; } = string.Empty;
}