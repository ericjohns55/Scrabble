using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using ScrabbleServer.Data.Web.Models.Types;
using ScrabbleServer.Utilities;

namespace ScrabbleServer.Data.Web.Attributes;

public class AcceptedTokenTypesAttribute : Attribute, IAsyncActionFilter
{
    private readonly TokenType _tokenType;

    public AcceptedTokenTypesAttribute(TokenType tokenType)
    {
        _tokenType = tokenType;
    }

    public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
    {
        var jwtToken = AuthUtilities.GetJwtFromContext(context.HttpContext);
        var tokenType = AuthUtilities.GetTokenType(jwtToken);

        if (tokenType == null || tokenType != _tokenType)
        {
            context.Result = new UnauthorizedResult();
            return;
        }

        await next();
    }
}