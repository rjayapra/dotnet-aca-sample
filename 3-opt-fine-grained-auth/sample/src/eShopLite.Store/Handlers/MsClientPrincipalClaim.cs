using System.Text.Json.Serialization;

namespace eShopLite.Store.Handlers;

public class MsClientPrincipalClaim
{
    [JsonPropertyName("typ")]
    public string? Type { get; set; }

    [JsonPropertyName("val")]
    public string? Value { get; set; }
}
