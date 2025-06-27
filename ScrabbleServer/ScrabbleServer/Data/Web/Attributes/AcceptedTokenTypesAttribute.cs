using System.IdentityModel.Tokens.Jwt;
using System.Net.Http.Headers;
using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using ScrabbleServer.Data.Web.Models.Types;

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
        var jwtToken = GetJwtFromContext(context.HttpContext);
        var tokenType = GetTokenType(jwtToken);

        if (tokenType == null || tokenType != _tokenType)
        {
            context.Result = new UnauthorizedResult();
            return;
        }

        await next();
    }
    
    
    private JwtSecurityToken GetJwtFromContext(HttpContext httpContext)
    {
        if (string.IsNullOrWhiteSpace(httpContext.Request.Headers["Authorization"]))
        {
            throw new UnauthorizedAccessException("Missing token");
        }
        
        if (AuthenticationHeaderValue.TryParse(httpContext.Request.Headers["Authorization"], out var authenticationHeaderValue))
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            return tokenHandler.ReadJwtToken(authenticationHeaderValue.Parameter);
        }
        
        throw new UnauthorizedAccessException("Invalid token");
    }

    private TokenType? GetTokenType(JwtSecurityToken jwtSecurityToken)
    {
        var tokenType = jwtSecurityToken.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Role)?.Value;

        if (!string.IsNullOrEmpty(tokenType))
        {
            if (TokenType.TryParse(tokenType, out TokenType token))
            {
                return token;
            }
        }

        return null;
    }
}