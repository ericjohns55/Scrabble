using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ScrabbleServer.Data.Models.DTOs;
using ScrabbleServer.Data.Web;
using ScrabbleServer.Data.Web.Attributes;
using ScrabbleServer.Data.Web.Models.Payloads;
using ScrabbleServer.Data.Web.Models.Types;
using ScrabbleServer.Services;

namespace ScrabbleServer.Controllers;

[Route("authentication")]
public class AuthenticationController : ScrabbleBaseController
{
    private readonly PlayerService _playerService;
    private readonly ILogger<AuthenticationController> _logger;

    public AuthenticationController(PlayerService playerService, ILogger<AuthenticationController> logger)
    {
        _playerService = playerService;
        _logger = logger;
    }

    [HttpGet]
    [AllowAnonymous]
    [Route("name-taken")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ScrabbleWebResponse<bool>))]
    public async Task<IActionResult> IsUsernameTaken([FromQuery] string displayName)
    {
        return Ok(await ExecuteToScrabbleResponseAsync(() => _playerService.IsDisplayNameTaken(displayName)));
    }

    [HttpPost]
    [AllowAnonymous]
    [Route("login")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ScrabbleWebResponse<TokensPayload>))]
    public async Task<IActionResult> Login([FromBody] CredentialsPayload credentialsPayload)
    {
        return Ok(await ExecuteToScrabbleResponseAsync(() => _playerService.Login(credentialsPayload)));
    }

    [HttpPost]
    [AllowAnonymous]
    [Route("register")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ScrabbleWebResponse<TokensPayload>))]
    public async Task<IActionResult> Register([FromBody] CredentialsPayload credentialsPayload)
    {
        return Ok(await ExecuteToScrabbleResponseAsync(() => _playerService.RegisterPlayer(credentialsPayload)));
    }

    [HttpPost]
    [AcceptedTokenTypes(TokenType.Refresh)]
    [Route("refresh")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ScrabbleWebResponse<TokensPayload>))]
    public IActionResult Tokens()
    {
        return Ok(ExecuteToScrabbleResponse(() =>
        {
            var currentUser = _playerService.GetSelf();
            return _playerService.GenerateTokens(currentUser);
        }));
    }
}