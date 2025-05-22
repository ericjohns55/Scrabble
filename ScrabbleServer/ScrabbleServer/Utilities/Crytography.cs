using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using ScrabbleServer.Data.Models.DTOs;

namespace ScrabbleServer.Utilities;

public class Crytography
{
    public static string ComputeHash(string input)
    {
        byte[] inputBytes = Encoding.ASCII.GetBytes(input);
        byte[] secretBytes = Encoding.ASCII.GetBytes(Constants.PASSWORD_KEY);

        using (var hmac = new HMACSHA256(secretBytes))
        {
            byte[] hashBytes = hmac.ComputeHash(inputBytes);
            return BitConverter.ToString(hashBytes).Replace("-", string.Empty);
        }
    }

    public static string CreateJwtFromUser(PlayerDTO player)
    {
        var claims = new[]
        {
            new Claim(ClaimTypes.Name, player.Username),
            new Claim(ClaimTypes.Sid, player.Uuid.ToString())
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(Constants.JWT_KEY));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        
        var token = new JwtSecurityToken(
            issuer: Constants.ISSUER,
            audience: Constants.AUDIENCE,
            claims: claims,
            expires: DateTime.Now.AddHours(1),
            signingCredentials: creds);
        
        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}