using System.Text.Json.Serialization;

namespace eShopLite.Store.Models;

public class ClientPrincipal
{
    [JsonPropertyName("auth_type")]
    public string? AuthType { get; set; }

    [JsonPropertyName("claims")]
    public List<PrincipalClaim> Claims { get; set; } = new();

    [JsonPropertyName("name_typ")]
    public string? NameType { get; set; }

    [JsonPropertyName("role_typ")]
    public string? RoleType { get; set; }
}

public class PrincipalClaim
{
    [JsonPropertyName("typ")]
    public string? Type { get; set; }

    [JsonPropertyName("val")]
    public string? Value { get; set; }
}
