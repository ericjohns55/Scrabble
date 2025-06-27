using Microsoft.AspNetCore.Mvc;
using ScrabbleServer.Data.Models.DTOs;
using ScrabbleServer.Data.Web;
using ScrabbleServer.Data.Web.Attributes;
using ScrabbleServer.Data.Web.Models.Payloads;
using ScrabbleServer.Data.Web.Models.Types;
using ScrabbleServer.Services;

namespace ScrabbleServer.Controllers;

[Route("games")]
[AcceptedTokenTypes(TokenType.Access)]
public class GameController : ScrabbleBaseController
{
    private readonly ILogger<GameController> _logger;
    private readonly GameService _gameService;
    private readonly PlayerService _playerService;

    public GameController(GameService gameService, PlayerService playerService, ILogger<GameController> logger)
    {
        _gameService = gameService;
        _playerService = playerService;
        _logger = logger;
    }

    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ScrabbleWebListResponse<GameDTO>))]
    public async Task<IActionResult> GetGames()
    {
        return Ok(await ExecuteToScrabbleListResponseAsync(async () =>
        {
            var currentPlayer = await _playerService.GetSelf(HttpContext);
            return await _gameService.GetGames(currentPlayer);
        }));
    }

    [HttpPost]
    [Route("create")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ScrabbleWebResponse<GameDTO>))]
    public async Task<IActionResult> CreateGame([FromBody] GameCreationPayload gameCreationPayload)
    {
        return Ok(await ExecuteToScrabbleResponseAsync(async () =>
        {
            var currentPlayer = await _playerService.GetSelf(HttpContext);
            return await _gameService.CreateGame(currentPlayer, gameCreationPayload);
        }));
    }

    [HttpGet]
    [Route("{gameId}")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ScrabbleWebResponse<GameDTO>))]
    public async Task<IActionResult> GetGame(Guid gameId)
    {
        return Ok(await ExecuteToScrabbleResponseAsync(() => _gameService.GetGameDto(gameId)));
    }

    [HttpPost]
    [Route("{gameId}/submit")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ScrabbleWebResponse<GameDTO>))]
    public async Task<IActionResult> SubmitMove(Guid gameId, [FromBody] GameMovePayload gameMovePayload)
    {
        return Ok(await ExecuteToScrabbleResponseAsync(async () =>
        {
            var currentPlayer = await _playerService.GetSelf(HttpContext);
            return await _gameService.UpdateGame(gameId, currentPlayer, gameMovePayload);
        }));
    }

    [HttpPost]
    [Route("{gameId}/decline")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ScrabbleWebResponse<GameDTO>))]
    public async Task<IActionResult> DeclineGame(Guid gameId)
    {
        return Ok(await ExecuteToScrabbleResponseAsync(async () =>
        {
            var currentPlayer = await _playerService.GetSelf(HttpContext);
            return await _gameService.DeclineGame(currentPlayer, gameId);
        }));
    }

    [HttpPost]
    [Route("{gameId}/accept")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ScrabbleWebResponse<GameDTO>))]
    public async Task<IActionResult> AcceptGame(Guid gameId)
    {
        return Ok(await ExecuteToScrabbleResponseAsync(async () =>
        {
            var currentPlayer = await _playerService.GetSelf(HttpContext);
            return await _gameService.AcceptGame(currentPlayer, gameId);
        }));
    }

    [HttpPost]
    [Route("{gameId}/forfeit")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ScrabbleWebResponse<GameDTO>))]
    public async Task<IActionResult> ForfeitGame(Guid gameId)
    {
        return Ok(await ExecuteToScrabbleResponseAsync(async () =>
        {
            var currentPlayer = await _playerService.GetSelf(HttpContext);
            return await _gameService.ForfeitGame(currentPlayer, gameId);
        }));
    }
}