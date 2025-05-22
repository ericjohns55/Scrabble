using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using ScrabbleServer.Data.Extensions;
using ScrabbleServer.Data.Web;

namespace ScrabbleServer.Controllers;

public class ScrabbleBaseController : Controller
{
    public static ScrabbleWebResponse<T> ExecuteToScrabbleResponse<T>(Func<T> func)
    {
        Stopwatch stopwatch = Stopwatch.StartNew();
        var data = func.Invoke();
        stopwatch.Stop();

        return new ScrabbleWebResponse<T>()
        {
            Data = data,
            ElapsedMilliseconds = stopwatch.ElapsedMilliseconds
        };
    }

    public static Task<ScrabbleWebResponse<T>> ExecuteToScrabbleResponseAsync<T>(Func<Task<T>> func)
    {
        Stopwatch stopwatch = Stopwatch.StartNew();

        return func.Invoke().OnSuccess(result =>
        {
            stopwatch.Stop();

            return new ScrabbleWebResponse<T>()
            {
                Data = result,
                ElapsedMilliseconds = stopwatch.ElapsedMilliseconds
            };
        });
    }

    public static Task<ScrabbleWebListResponse<T>> ExecuteToScrabbleListResponseAsync<T>(Func<Task<List<T>>> func)
    {
        Stopwatch stopwatch = Stopwatch.StartNew();

        return func.Invoke().OnSuccess(result =>
        {
            stopwatch.Stop();

            return new ScrabbleWebListResponse<T>()
            {
                Data = result,
                ElapsedMilliseconds = stopwatch.ElapsedMilliseconds
            };
        });
    }
} 