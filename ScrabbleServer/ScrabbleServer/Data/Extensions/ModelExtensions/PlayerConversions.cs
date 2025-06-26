using ScrabbleServer.Data.Models.DatabaseModels;
using ScrabbleServer.Data.Models.DTOs;

namespace ScrabbleServer.Data.Extensions.ModelExtensions;

public static class PlayerConversions
{
    public static PlayerDTO ToDTO(this Player player)
    {
        return new PlayerDTO()
        {
            Id = player.Id,
            Uuid = player.Uuid,
            Username = player.Username,
            ProfilePicture = player.ProfilePicture,
            CreatedDate = player.CreatedDate,
            UpdatedDate = player.UpdatedDate
        };
    }
}