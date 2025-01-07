# EP03: Authenticating App on ACA &ndash; Extra

This section is totally optional and demonstrates a more advance technique to extend the [authentication and authorization feature](https://learn.microsoft.com/azure/container-apps/authentication) for [Azure Container Apps (ACA)](https://learn.microsoft.com/azure/container-apps/overview).

## Prerequisites

You have done and completed the [ep03](README.md) content.

### Getting the repository root

Initialize the variable `REPOSITORY_ROOT` in your preferred terminal.

```bash
# Bazh/Zsh
REPOSITORY_ROOT=$(git rev-parse --show-toplevel)
```

```powershell
# PowerShell
$REPOSITORY_ROOT = git rev-parse --show-toplevel
```

## Extending Authorization for ACA

Once you have the built-in authentication feature enabled on ACA, you will have the `x-ms-client-principal` header in every request. You will have to convert this header to ASP.NET Core's `ClaimsPrincipal` to authorize the user.

1. Make sure that you're in the `ep03` directory.

    ```bash
    cd $REPOSITORY_ROOT/ep03
    ```

1. Open the `src/eShopLite.Store/Program.cs` file and find the `var app = builder.Build();` line. Then, add the following code just above it.

    ```csharp
    builder.Services.AddAuthentication(EasyAuthAuthenticationHandler.EASY_AUTH_SCHEME_NAME)
                    .AddAzureEasyAuthHandler();
    builder.Services.AddAuthorization();
    ```

   > **NOTE**: You might be asked to add the `using eShopLite.Store.Handlers;` line at the top of the file.

1. In the same `src/eShopLite.Store/Program.cs` file, find the `app.Run();` line and add the following code just above it.

    ```csharp
    app.UseAuthentication();
    app.UseAuthorization();
    ```

1. Open the `src/eShopLite.Store/Components/Pages/Products.razor` file and add the following codes.

    ```razor
    @page "/products"
    
    @* 👇👇👇 Add the line below *@
    @using Microsoft.AspNetCore.Authorization
    @* 👆👆👆 Add the line above *@
    
    ...
    
    @* 👇👇👇 Add the line below *@
    @attribute [Authorize(AuthenticationSchemes = "EasyAuth")]
    @* 👆👆👆 Add the line above *@
    ```

1. Run the following command to update the existing app on ACA.

    ```bash
    azd deploy
    ```

   > **NOTE**: If you've already cleaned up all the resources, you should start from `azd up` first.

1. Visit the Blazor app on ACA and navigate to the `/products` page. You should see the `401 Unauthorized` error.
1. Navigate back to the home page and click the "Login" button on the top-right corner and sign in with your account.
1. Navigate to the `/products` page again. You should see the list of products.

## Clean up the deployed resources

To clean up the resources, run the following command:

```bash
azd down --force --purge
```
