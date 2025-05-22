namespace ScrabbleServer.Data.Models.DTOs;

public class PlayerDTO
{
    public int PlayerId { get; init; }

    public Guid Uuid { get; init; }

    public string Username { get; init; } = string.Empty;

    public string? ProfilePicture { get; init; }

    public DateTime CreatedDate { get; init; }
    
    public DateTime UpdatedDate { get; init; }
}