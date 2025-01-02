using System.Text.Json;

using eShopLite.Store.Models;

namespace eShopLite.Store.Services;

public interface IAuthenticationService
{
    Task<bool> IsAuthenticatedAsync();
    Task<string?> GetDisplayNameAsync();
}

public class AuthenticationService(IHttpContextAccessor accessor) : IAuthenticationService
{
    private readonly IHttpContextAccessor _accessor = accessor ?? throw new ArgumentNullException(nameof(accessor));

    private ClientPrincipal? _principal;

    public async Task<bool> IsAuthenticatedAsync()
    {
        var req = _accessor.HttpContext!.Request;
        var encoded = this.GetClientPrincipalHeader(req);
        if (string.IsNullOrWhiteSpace(encoded) == true)
        {
            return false;
        }

        this._principal = await this.GetClientPrincipalAsync(encoded).ConfigureAwait(false);

        var isAuthenticated = this._principal != null && this._principal.Claims.Count != 0;

        return isAuthenticated;
    }

    public async Task<string?> GetDisplayNameAsync()
    {
        if (this._principal == null)
        {
            var req = _accessor.HttpContext!.Request;
            var encoded = this.GetClientPrincipalHeader(req);
            this._principal = await this.GetClientPrincipalAsync(encoded).ConfigureAwait(false);
        }

        var displayName = this._principal.Claims.FirstOrDefault(c => c.Type == "name")?.Value;

        return displayName;
    }

    private string GetClientPrincipalHeader(HttpRequest req)
    {
        var value = req.Headers["X-MS-CLIENT-PRINCIPAL"];

        return value!;
    }

    private async Task<ClientPrincipal> GetClientPrincipalAsync(string encoded)
    {
        var decoded = Convert.FromBase64String(encoded!);
        using var stream = new MemoryStream(decoded);
        var clientPrincipal = await JsonSerializer.DeserializeAsync<ClientPrincipal>(stream).ConfigureAwait(false);

        return clientPrincipal!;
    }
}
