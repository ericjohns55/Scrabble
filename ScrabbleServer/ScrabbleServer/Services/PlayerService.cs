using System.Security.Authentication;
using System.Security.Claims;
using System.Text.RegularExpressions;
using Microsoft.EntityFrameworkCore;
using ScrabbleServer.Data;
using ScrabbleServer.Data.Exceptions;
using ScrabbleServer.Data.Extensions.ModelExtensions;
using ScrabbleServer.Data.Models.DatabaseModels;
using ScrabbleServer.Data.Models.DTOs;
using ScrabbleServer.Data.Web.Payloads;
using ScrabbleServer.Utilities;

namespace ScrabbleServer.Services;

public class PlayerService
{
    private readonly ScrabbleContext _scrabbleContext;
    private readonly ILogger<PlayerService> _logger;

    public PlayerService(ScrabbleContext scrabbleContext, ILogger<PlayerService> logger)
    {
        _scrabbleContext = scrabbleContext;
        _logger = logger;
    }

    public Task<List<PlayerDTO>> GetPlayers()
    {
        return _scrabbleContext.Players.Select(player => player.ToDTO()).ToListAsync();
    }

    public async Task<PlayerDTO> GetSelf(HttpContext httpContext)
    {
        var displayName = httpContext.User.Identity?.Name;
        var uuid = httpContext.User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Sid)?.Value;

        if (string.IsNullOrWhiteSpace(displayName) || string.IsNullOrWhiteSpace(uuid))
        {
            throw new UnauthorizedAccessException("You are not authorized to access this resource.");
        }

        var player = await _scrabbleContext.Players
            .SingleOrDefaultAsync(player => player.Username == displayName && player.Uuid == Guid.Parse(uuid));

        if (player == null)
        {
            throw new UnauthorizedAccessException("You are not authorized to access this resource.");
        }
        
        return player.ToDTO();
    }

    public Task<bool> IsDisplayNameTaken(string displayName)
    {
        return _scrabbleContext.Players.AnyAsync(player => player.Username == displayName);
    }

    public async Task<TokensPayload> Login(CredentialsPayload credentialsPayload)
    {
        var user = await _scrabbleContext.Players
            .FirstOrDefaultAsync(player => player.Username == credentialsPayload.Username
                                           && player.Password == Crytography.ComputeHash(credentialsPayload.Password));

        if (user == null)
        {
            throw new AuthenticationException("Could not login.");
        }
        
        return new TokensPayload()
        {
            AuthenticationToken = Crytography.CreateJwtFromUser(user.ToDTO())
        };
    }

    public async Task<PlayerDTO> RegisterPlayer(CredentialsPayload credentialsPayload)
    {
        if (string.IsNullOrWhiteSpace(credentialsPayload.Username))
        {
            throw new ArgumentException("Username is required.");
        }
        
        if (string.IsNullOrWhiteSpace(credentialsPayload.Password))
        {
            throw new ArgumentException("Password is required.");
        }

        if (credentialsPayload.Username.Length < 3 || credentialsPayload.Username.Length > 64)
        {
            throw new InvalidDisplayNameException("Username must be between 3-64 characters.");
        }

        if (!Regex.IsMatch(credentialsPayload.Username, @"^[a-zA-Z0-9_\-\.]+$"))
        {
            throw new InvalidDisplayNameException("Invalid characters found in display name.");
        }
        
        if (_scrabbleContext.Players.Any(player => player.Username == credentialsPayload.Username))
        {
            throw new DisplayNameTakenException($"Username {credentialsPayload.Username} already taken.");
        }

        var newPlayer = new Player()
        {
            Uuid = Guid.NewGuid(),
            Username = credentialsPayload.Username,
            Password = Crytography.ComputeHash(credentialsPayload.Password),
            ProfilePicture = null,
            CreatedDate = DateTime.UtcNow,
            UpdatedDate = DateTime.UtcNow
        };
        
        await _scrabbleContext.Players.AddAsync(newPlayer);
        await _scrabbleContext.SaveChangesAsync();

        return newPlayer.ToDTO();
    }
}