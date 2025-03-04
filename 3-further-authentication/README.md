# Extending authentication and authorization on ACA

The built-in [EasyAuth feature](https://learn.microsoft.com/azure/container-apps/authentication) for [Azure Container Apps (ACA)](https://learn.microsoft.com/azure/container-apps/overview) only takes care of your application being protected from unauthenticated visitors. However, in many cases, you want to allow visitors at least to see the landing page without having to login, while the other pages remain protected.

This requires you to add some codes for authorization. Let's dig deeper how to augment the built-in EasyAuth feature with applying authorization to individual pages.

## Prerequisites

You have done and completed the [previous episode](../3-authentication/README.md) that explains the built-in EasyAuth feature.

### Getting the repository root

Initialize the variable `REPOSITORY_ROOT` in your preferred terminal.

```bash
# bazh/zsh
REPOSITORY_ROOT=$(git rev-parse --show-toplevel)
```

```powershell
# PowerShell
$REPOSITORY_ROOT = git rev-parse --show-toplevel
```

### Deploy the application to ACA via Azure Developer CLI (AZD)

1. Make sure that you're in the `3-further-authentication/sample` directory.

    ```bash
    cd $REPOSITORY_ROOT/3-further-authentication/sample
    ```

1. Run the following command to deploy a new application to ACA.

    ```bash
    azd up
    ```

   > 📝**NOTE:**
   > While executing this command, you'll be asked to provide the Azure subscription ID and location.

1. Open your web browser and navigate to the URL provided by the ACA instance on the screen to see the monolith app running in ACA.
1. You'll see the landing page. Navigate to the `/products` and see the `401 Unauthorized` error.
1. Navigate back to the landing page. At the top-right corner, click the **Login** button to see the built-in authentication feature of ACA in action.

   ![Landing page - before login](./images/landing-page-before-login.png)

   You will be redirected to the Microsoft Entra ID login page with Entra ID consent.

   ![Entra ID consent](./images/entraid-consent.png)

   After successful login, you will be redirected back to the monolith app.

   ![Landing page - after login](./images/landing-page-after-login.png)

1. Navigate to the `/products` page again. You should see the list of products.

### What's happening?

There's a magic behind. After enabling the built-in EasyAuth feature, your sign-in details are securely stored. Every time you navigate pages, the access token is passed through the request header, `x-ms-client-principal` so that the Blazor app recognizes you are the authenticated user. However, as this access token is different from what the Blazor application understands, the application doesn't know how to apply authorization. Therefore, the access token should be converted for the Blazor app to understand.

There's a custom handler code for the conversion, called `EasyAuthAuthenticationHandler`. It reads the access token from `x-ms-client-principal` and converts it to the `ClaimsPrincipal` instance so that the Blazor app now finally understands how to apply authorization for each page.

If you want to deep further, please analyze this handler code: [https://github.com/Azure-Samples/dotnet-on-aca-for-beginners/blob/main/ep03-1/sample/src/eShopLite.Store/Handlers/EasyAuthAuthenticationHandler.cs](https://github.com/Azure-Samples/dotnet-on-aca-for-beginners/blob/main/ep03-1/sample/src/eShopLite.Store/Handlers/EasyAuthAuthenticationHandler.cs).

## Clean up the deployed resources

To clean up the resources, run the following command:

```bash
azd down --force --purge
```

## Optional Learning

- [Azure EasyAuth Extensions](https://github.com/aliencube/azure-easyauth-extensions): Community contributions for Azure EasyAuth handler library
