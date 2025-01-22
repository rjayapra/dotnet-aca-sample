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

## Allowing Anonymous Access to ACA

1. Make sure that you're in the `ep03` directory.

    ```bash
    cd $REPOSITORY_ROOT/ep03
    ```

1. Open `infra/resources.bicep` and find the module that calls `modules/containerapps-authconfigs.bicep`. Change the `unauthenticatedClientAction` value from `RedirectToLoginPage` to `AllowAnonymous`. This change allows users to access to the entire ACA app without having to sign-in.

    ```bicep
    module eshopLiteStoreAuthConfig './modules/containerapps-authconfigs.bicep' = {
      name: 'eshopLiteStoreAuthConfig'
      params: {
        containerAppName: eshopLiteStore.outputs.name
        managedIdentityName: eshopLiteStoreIdentity.outputs.name
        storageAccountName: storageAccount.outputs.name
        clientId: appRegistration.outputs.appId
        openIdIssuer: issuer
    
        // 👇👇👇 Remove the line below
        unauthenticatedClientAction: 'RedirectToLoginPage'
        // 👆👆👆 Remove the line above
    
        // 👇👇👇 Add the line below
        unauthenticatedClientAction: 'AllowAnonymous'
        // 👆👆👆 Add the line above
      }
    }
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

### Deploying the Updated App to ACA via Azure Developer CLI (AZD)

1. Make sure that you're in the `ep03` directory.

    ```bash
    cd $REPOSITORY_ROOT/ep03
    ```

1. With all changes, run the following command to update the existing app on ACA.

    ```bash
    azd up
    ```

1. Open your web browser and navigate to the URL provided by the ACA instance on the screen to see the monolith app running in ACA.
1. You'll see the landing page. Navigate to the `/products` and see the `401 Unauthorized` error.
1. Navigate back to the landing page. At the top-right corner, click the **Login** button to see the built-in authentication feature of ACA in action.

   ![Landing page - before login](./images/ep03-01.png)

   You will be redirected to the Microsoft Entra ID login page.

   After successful login, you will be redirected back to the monolith app.

   ![Landing page - after login](./images/ep03-03.png)

1. Navigate to the `/products` page again. You should see the list of products.

## Clean up the deployed resources

To clean up the resources, run the following command:

```bash
azd down --force --purge
```
