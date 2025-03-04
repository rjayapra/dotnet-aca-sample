# Extending authentication and authorization on ACA

The built-in [EasyAuth feature](https://learn.microsoft.com/azure/container-apps/authentication) for [Azure Container Apps (ACA)](https://learn.microsoft.com/azure/container-apps/overview) only takes care of your application being protected from unauthenticated visitors. However, in many cases, you want to allow visitors at least to see the landing page without having to login, while the other pages remain protected.

This requires you to add some code for authorization. Let's dig deeper how to augment the built-in EasyAuth feature with applying authorization to individual pages.

## Prerequisites

You have done and completed the [previous chapter](../3-authentication/) that explains the built-in EasyAuth feature.

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

> 📝**NOTE**: If you already have an environment from a previous chapter, you can skip this part on deployment.
> 

1. Make sure that you're in the **3-opt-fine-grained-auth** directory.

    ```bash
    cd $REPOSITORY_ROOT/3-opt-fine-grained-auth/sample
    ```

1. Run the following command to deploy a new application to ACA. (We've already provided all the bicep and infrastructure files you need.)

    ```bash
    azd up
    ```

   > 📝**NOTE:**
   > While executing this command, you'll be asked to provide the Azure subscription ID and location.

### Explore the fine-grained authentication

1. Open your web browser and navigate to your application (either provided by the azd output or obtained via the Azure Portal).
2. You'll see the landing page. 
3. Navigate to the `/products` and see `401 Unauthorized` error.
4. Navigate back to the landing page. At the top-right corner, click the **Login** button to see the built-in authentication feature of ACA in action.

   ![Landing page - before login](./images/before-login.png)

   You will be redirected to the Microsoft Entra ID login page.

   After successful login, you will be redirected back to the monolith app.

   ![Landing page - after login](./images/after-login.png)

5. Navigate to the `/products` page again. You should see the list of products.

So to reiterate what happened - the main landing page was not authenticated. It was viewable by anybody at any time. But the `/products/` page required users to be signed-in to view.

### What's happening?

After enabling the built-in EasyAuth feature, your sign-in details are securely stored. 

Every time you navigate pages, the access token is passed through the request header, `x-ms-client-principal` so that the Blazor app recognizes you are the authenticated user.

However, the Blazor application doesn't understand the format of the access token. So it doesn't know how to apply authorization. So we need to covert the access token for the Blazor app to understand it.

To help with that, we created a class called `EasyAuthenticationHandler`. It's a custom handler class that reads the access token from `x-ms-client-principal` and converts it to the `ClaimsPrincipal` instance so that the Blazor app can apply authorization to each page.

Then to make sure a page requires authentication add the `@attribute [Authorize(AuthenticationSchemes = "EasyAuth")]` attribute to the top of the page itself.

So now we have a rudimentary authorization scheme as well.

Digging into the specifics of how `EasyAuthenticationHandler` is implemented is a bit beyond the scope of this course. But you can checkout the code in the `sample\src\eShopLite.Store\Handlers` directory.

## Learn more

**TODO: ADD LEARN MORE RESOURCES**

## Clean up the deployed resources

You are running in Azure and depending on your subscription may be incurring costs. Run the following command to delete everything you have provisioned. 

```bash
azd down --force --purge
```

## Up next

Azure Container Apps really shines when hosting a microservice architecture. In the next chapter find out how we can refactor our app into microservices and get them talking to each other.

👉 [Chapter 4: Refactoring to microservices](../4-microservices/)
