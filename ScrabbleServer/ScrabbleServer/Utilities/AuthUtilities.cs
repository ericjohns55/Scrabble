using System.IdentityModel.Tokens.Jwt;
using System.Net.Http.Headers;
using System.Security.Claims;
using ScrabbleServer.Data.Web.Models.Types;

namespace ScrabbleServer.Utilities;

public class AuthUtilities
{
    public static JwtSecurityToken GetJwtFromContext(HttpContext httpContext)
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

    public static TokenType? GetTokenType(JwtSecurityToken jwtSecurityToken)
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