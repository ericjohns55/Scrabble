using System.Security.Claims;
using Microsoft.EntityFrameworkCore;
using ScrabbleServer.Data.Models.DatabaseModels;

namespace ScrabbleServer.Contexts;

public class ScrabbleContext
{
    public DatabaseContext DatabaseContext { get; init; }
    public Player? Player { get; init; }

    public ScrabbleContext(DatabaseContext databaseContext, IHttpContextAccessor httpContextAccessor)
    {
        DatabaseContext = databaseContext;

        if (httpContextAccessor.HttpContext != null)
        {
            Player = GetPlayerFromContext(httpContextAccessor.HttpContext);
        }
    }

    public ScrabbleContext(DatabaseContext databaseContext, Player player)
    {
        DatabaseContext = databaseContext;
        Player = player;
    }

    public Player GetCurrentPlayerOrThrow()
    {
        if (Player == null)
        {
            throw new UnauthorizedAccessException("You are not authorized");
        }

        return Player;
    }

    private Player? GetPlayerFromContext(HttpContext httpContext)
    {
        var displayName = httpContext.User.Identity?.Name;
        var uuid = httpContext.User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Sid)?.Value;

        if (Guid.TryParse(uuid, out Guid parsedGuid))
        {
            return DatabaseContext.Players
                .AsNoTracking()
                .SingleOrDefault(player => player.Username == displayName && player.Uuid == parsedGuid);
        }

        return null;
    }
}