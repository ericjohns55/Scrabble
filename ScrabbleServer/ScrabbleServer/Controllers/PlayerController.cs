using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ScrabbleServer.Data.Models.DTOs;
using ScrabbleServer.Data.Web;
using ScrabbleServer.Data.Web.Attributes;
using ScrabbleServer.Data.Web.Models.Types;
using ScrabbleServer.Services;

namespace ScrabbleServer.Controllers;

[Authorize]
[Route("players")]
[AcceptedTokenTypes(TokenType.Access)]
public class PlayerController : ScrabbleBaseController
{
    private readonly PlayerService _playerService;
    private readonly ILogger<PlayerController> _logger;

    public PlayerController(PlayerService playerService, ILogger<PlayerController> logger)
    {
        _playerService = playerService;
        _logger = logger;
    }

    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ScrabbleWebListResponse<PlayerDTO>))]
    public async Task<IActionResult> GetPlayers([FromQuery] bool includeSelf = true)
    {
        return Ok(await ExecuteToScrabbleListResponseAsync(() => _playerService.GetPlayers(includeSelf)));
    }

    [HttpGet]
    [Route("self")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ScrabbleWebListResponse<PlayerDTO>))]
    public IActionResult GetSelf()
    {
        return Ok(ExecuteToScrabbleResponse(() => _playerService.GetSelf()));
    }

    [HttpGet]
    [Route("{playerId}")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ScrabbleWebResponse<PlayerDTO>))]
    public async Task<IActionResult> GetPlayer(Guid playerId)
    {
        return Ok(await ExecuteToScrabbleResponseAsync(() => _playerService.GetPlayer(playerId)));
    }
}