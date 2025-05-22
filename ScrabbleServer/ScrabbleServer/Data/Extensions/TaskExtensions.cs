namespace ScrabbleServer.Data.Extensions;

public static class TaskExtensions
{
    private static void CheckTaskSuccess(
        Task task,
        Action<Exception>? errorFunction,
        Action? cancelFunction)
    {
        if (task.IsFaulted)
        {
            if (errorFunction != null)
            {
                errorFunction.Invoke(task.Exception);
            }
        }

        if (task.IsCanceled)
        {
            if (cancelFunction != null)
            {
                cancelFunction.Invoke();
            }
        }
    }
    
    private static void CheckTaskSuccess<TResult>(
        Task task,
        Func<Exception, TResult>? errorFunction,
        Action? cancelFunction)
    {
        if (task.IsFaulted)
        {
            if (errorFunction != null)
            {
                errorFunction.Invoke(task.Exception);
            }
        }

        if (task.IsCanceled)
        {
            if (cancelFunction != null)
            {
                cancelFunction.Invoke();
            }
        }
    }

    private static bool TaskFailed(Task t)
    {
        return t.IsFaulted && t.Exception != null;
    }
    
    public static Task<TNewResult> OnSuccess<TResult, TNewResult>(
        this Task<TResult> task,
        Func<TResult, TNewResult> onSuccessFunction,
        Func<Exception, TNewResult>? onErrorFunction = null,
        Action? cancelFunction = null)
    {
        return task.ContinueWith(t =>
        {
            CheckTaskSuccess(t, onErrorFunction, cancelFunction);
            return onSuccessFunction(t.Result);
        }, TaskContinuationOptions.ExecuteSynchronously);
    }

    public static Task OnFailure(
        this Task task,
        Func<Exception, Task> onFailureFunction)
    {
        return task.ContinueWith(t =>
        {
            if (TaskFailed(task))
            {
                return onFailureFunction(t.Exception?.GetBaseException());
            }

            return task;
        }, TaskContinuationOptions.ExecuteSynchronously);
    }

    public static Task<TResult> FinishWith<TResult>(
        this Task<TResult> task,
        Action finishFunction,
        Action<Exception>? onErrorFunction = null,
        Action? cancelFunction = null)
    {
        return task.ContinueWith(t =>
        {
            CheckTaskSuccess(t, onErrorFunction, cancelFunction);
            finishFunction.Invoke();
            return t.Result;
        }, TaskContinuationOptions.ExecuteSynchronously);
    }

    public static TResult WaitForCompletion<TResult>(this Task<TResult> task)
    {
        task.Wait();
        CheckTaskSuccess(task, null, null);
        return task.Result;
    }
}