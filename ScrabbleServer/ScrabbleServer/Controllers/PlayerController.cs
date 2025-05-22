using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ScrabbleServer.Data.Models.DTOs;
using ScrabbleServer.Data.Web;
using ScrabbleServer.Services;

namespace ScrabbleServer.Controllers;

[Authorize]
[Route("players")]
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
    public async Task<IActionResult> GetPlayers()
    {
        return Ok(await ExecuteToScrabbleListResponseAsync(() => _playerService.GetPlayers()));
    }

    [HttpGet("self")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ScrabbleWebListResponse<PlayerDTO>))]
    public async Task<IActionResult> GetSelf()
    {
        return Ok(await ExecuteToScrabbleResponseAsync(() => _playerService.GetSelf(HttpContext)));
    }
}