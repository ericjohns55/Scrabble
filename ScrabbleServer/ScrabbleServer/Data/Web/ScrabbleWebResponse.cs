namespace ScrabbleServer.Data.Web;

public class ScrabbleWebResponse<T>
{
    public T Data { get; init; }
    public long ElapsedMilliseconds { get; init; }
}

public class ScrabbleWebListResponse<T> : ScrabbleWebResponse<T>
{
    public new List<T> Data { get; init; }
    public int Count => Data.Count;
}