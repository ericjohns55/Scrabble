using Microsoft.AspNetCore.Mvc;
using ScrabbleServer.Data.Web;
using ScrabbleServer.Data.Web.Attributes;
using ScrabbleServer.Data.Web.Models.Types;

namespace ScrabbleServer.Controllers;

[Route("games")]
[AcceptedTokenTypes(TokenType.Access)]
public class GameController : ScrabbleBaseController
{
    private readonly ILogger<GameController> _logger;

    public GameController(ILogger<GameController> logger)
    {
        _logger = logger;
    }

    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ScrabbleWebResponse<string>))]
    public IActionResult TestEndpoint()
    {
        _logger.LogInformation("Testing endpoint");
        return Ok(ExecuteToScrabbleResponse(() => "Test response"));
    }
}