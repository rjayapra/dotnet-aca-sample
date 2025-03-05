using Microsoft.AspNetCore.Authentication;

namespace eShopLite.Store.Handlers;

public class EasyAuthAuthenticationOptions : AuthenticationSchemeOptions
{
    public EasyAuthAuthenticationOptions()
    {
        Events = new object();
    }
}
