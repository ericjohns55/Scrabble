using System.Net;
using System.Net.Mime;
using System.Security.Authentication;
using System.Text.Json;
using ScrabbleServer.Data.Exceptions;
using ScrabbleServer.Data.Extensions;
using ScrabbleServer.Data.Web;

namespace ScrabbleServer;

public class ExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionMiddleware> _logger;

    public ExceptionMiddleware(RequestDelegate next, ILogger<ExceptionMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public Task InvokeAsync(HttpContext context)
    {
        return _next.Invoke(context).OnFailure(exception => HandleExceptionAsync(context, exception));
    }

    public Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        var rootException = exception.GetBaseException();
        var statusCode = GetHttpStatusCode(rootException);

        context.Response.ContentType = MediaTypeNames.Application.Json;
        context.Response.StatusCode = (int) statusCode;

        var stackTrace = rootException.StackTrace;

        if (context.Request.Headers.TryGetValue("User-Agent", out var userAgent))
        {
            if (userAgent.Any(agent => agent?.Contains("swift-app") ?? false))
            {
                stackTrace = null; // exclude stack traces from swift app
            }
        }

        ScrabbleExceptionResponse errorResponse = new ScrabbleExceptionResponse()
        {
            StatusCode = (int)statusCode,
            Identifier = context.TraceIdentifier,
            Route = context.Request.Path,
            Message = rootException.Message,
            Details = stackTrace ?? string.Empty
        };
        
        var serializedResponse = JsonSerializer.Serialize(errorResponse, new JsonSerializerOptions()
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        });
        
        _logger.LogError($"[{context.TraceIdentifier}] Exception occured: {errorResponse.Message}\n{exception.StackTrace}");
        
        return context.Response.WriteAsync(serializedResponse);
    }

    private HttpStatusCode GetHttpStatusCode(Exception exception)
    {
        switch (exception)
        {
            case AuthenticationException:
            case UnauthorizedAccessException:
                return HttpStatusCode.Unauthorized;
            case ArgumentException:
            case InvalidDisplayNameException:
            case AlreadyPlayedException:
            case InvalidGameCreationException: 
            case InvalidUserException:
            case GameException:
                return HttpStatusCode.BadRequest;
            case ItemNotFoundException:
                return HttpStatusCode.NotFound;
            case DisplayNameTakenException:
                return HttpStatusCode.Conflict;
            default:
                return HttpStatusCode.InternalServerError;
        }
    }
}