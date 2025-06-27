using Microsoft.AspNetCore.Mvc;
using ScrabbleServer.Contexts;
using ScrabbleServer.Data.Models.DatabaseModels;
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
    private readonly ScrabbleContext _scrabbleContext;
    private readonly GameService _gameService;

    private Player CurrentPlayer => _scrabbleContext.GetCurrentPlayerOrThrow();

    public GameController(GameService gameService, ScrabbleContext scrabbleContext, ILogger<GameController> logger)
    {
        _gameService = gameService;
        _scrabbleContext = scrabbleContext;
        _logger = logger;
    }

    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ScrabbleWebListResponse<GameDTO>))]
    public async Task<IActionResult> GetGames()
    {
        // TODO: game status query param
        return Ok(await ExecuteToScrabbleListResponseAsync(() => _gameService.GetGames(CurrentPlayer)));
    }

    [HttpPost]
    [Route("create")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ScrabbleWebResponse<GameDTO>))]
    public async Task<IActionResult> CreateGame([FromBody] GameCreationPayload gameCreationPayload)
    {
        return Ok(await ExecuteToScrabbleResponseAsync(() => _gameService.CreateGame(CurrentPlayer, gameCreationPayload)));
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
        return Ok(await ExecuteToScrabbleResponseAsync(() => _gameService.UpdateGame(gameId, CurrentPlayer, gameMovePayload)));
    }

    [HttpPost]
    [Route("{gameId}/decline")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ScrabbleWebResponse<GameDTO>))]
    public async Task<IActionResult> DeclineGame(Guid gameId)
    {
        return Ok(await ExecuteToScrabbleResponseAsync(() => _gameService.DeclineGame(CurrentPlayer, gameId)));
    }

    [HttpPost]
    [Route("{gameId}/accept")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ScrabbleWebResponse<GameDTO>))]
    public async Task<IActionResult> AcceptGame(Guid gameId)
    {
        return Ok(await ExecuteToScrabbleResponseAsync(() => _gameService.AcceptGame(CurrentPlayer, gameId)));
    }

    [HttpPost]
    [Route("{gameId}/forfeit")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ScrabbleWebResponse<GameDTO>))]
    public async Task<IActionResult> ForfeitGame(Guid gameId)
    {
        return Ok(await ExecuteToScrabbleResponseAsync(() => _gameService.ForfeitGame(CurrentPlayer, gameId)));
    }
}