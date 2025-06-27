using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ScrabbleServer.Data.Models.DatabaseModels;

[Table("PLAYER")]
public class Player
{
    [Column("ID")]
    public long Id { get; init; }

    [Column("UUID")] 
    public Guid Uuid { get; init; }
    
    [Required]
    [MaxLength(64)]
    [Column("USERNAME")]
    public string Username { get; init; } = string.Empty;
    
    [Required]
    [MaxLength(256)]
    [Column("PASSWORD")]
    public string Password { get; init; } = string.Empty;
    
    [MaxLength(8192)]
    [Column("PROFILE_PICTURE")]
    public string? ProfilePicture { get; set; } = string.Empty;
    
    [Column("CREATED_DATE")]
    public DateTime CreatedDate { get; init; }
    
    [Column("UPDATED_DATE")]
    public DateTime UpdatedDate { get; init; }
}