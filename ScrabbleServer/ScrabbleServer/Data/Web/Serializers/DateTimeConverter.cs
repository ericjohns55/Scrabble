using System.Text.Json;
using System.Text.Json.Serialization;

namespace ScrabbleServer.Data.Web.Serializers;

public class DateTimeConverter : JsonConverter<DateTime>
{
    private const string TimeFormat = "yyyy-MM-dd'T'HH:mm:ss";

    public override DateTime Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        return DateTime.Parse(reader.GetString()!);
    }

    public override void Write(Utf8JsonWriter writer, DateTime value, JsonSerializerOptions options)
    {
        writer.WriteStringValue(value.ToString(TimeFormat));
    }
}