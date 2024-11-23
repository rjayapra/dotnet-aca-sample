# EP02: Monolith App on ACA

This sample app demonstrates how to containerize and deploy a monolith app (Blazor web app) to [Azure Container Apps (ACA)](https://learn.microsoft.com/en-us/azure/container-apps/overview).

## Prerequisites

To run this sample app, you need the following tools installed on your machine:

- [.NET 9 SDK](https://dotnet.microsoft.com/download/dotnet/9.0)
- [Visual Studio 2022 ](https://visualstudio.microsoft.com/vs/) or [Visual Studio Code](https://code.visualstudio.com/) with [C# Dev Kit extension](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csdevkit)
- [Docker Desktop](https://docs.docker.com/desktop/)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) with [Azure Container Apps extension](https://learn.microsoft.com/cli/azure/azure-cli-extensions-list)
- [Azure Developer CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)

**For Windows users**:

- Make sure that you have [WSL2](https://learn.microsoft.com/windows/wsl/install) enabled and installed a Linux distro like Debian or Ubuntu on your machine.
- Make sure that you have [PowerShell 7+](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-windows) installed on your machine.

## Getting Started

### Getting the repository root

```bash
# Bazh/Zsh
REPOSITORY_ROOT=$(git rev-parse --show-toplevel)
```

```powershell
# PowerShell
$REPOSITORY_ROOT = git rev-parse --show-toplevel
```

### Running the Monolith App Locally

To build and run this monolith web app on your local machine, run the following commands in your terminal.

1. Build the app.

    ```bash
    dotnet restore $REPOSITORY_ROOT/ep02 && dotnet build $REPOSITORY_ROOT/ep02
    ```

1. Run the app.

    ```bash
    dotnet watch run --project $REPOSITORY_ROOT/ep02/src/eShopLite.Store
    ```

### Containerizing the Monolith App

There are a few steps to containerize this monolith app using Docker.

1. Move to the `ep02` directory.

    ```bash
    cd $REPOSITORY_ROOT/ep02
    ```

1. Build the container image using Docker CLI.

    ```bash
    docker build . -f ./Dockerfile.store -t eshoplite-store:latest
    ```

### Running the Monolith App in a Container

Once you have the container image of the monolith app, you can run it in a container.

1. Run the following command to run the monolith app in a container.

    ```bash
    docker run -d -p 8080:8080 --name eshoplite-store eshoplite-store:latest
    ```

1. Check your container is up and running:

    ```bash
    docker ps
    ```

   If the container is up and running, you should see an output similar to the following:

    ```bash
    CONTAINER ID   IMAGE                    COMMAND                  CREATED        STATUS          PORTS                    NAMES
    1b7b4b8b6b6d   eshoplite-store:latest   "dotnet eShopLite.St…"   1 minute ago   Up 1 minute     0.0.0.0:8080->8080/tcp   eshoplite-store
    ```

1. Open your web browser and navigate to `http://localhost:8080` to see the monolith app running in a container.

### Deploying the Monolith App to ACA via Azure CLI

Once you're happy with the monoith app running in a container, you can deploy it to ACA.

1. Set environment variables like `AZURE_ENV_NAME` and `AZURE_LOCATION`. `{{LOCATION}}` is the Azure region where you want to deploy the resources.

    ```bash
    # Bash/Zsh
    AZURE_ENV_NAME="acadotnet$(($RANDOM%9000+1000))"
    AZURE_LOCATION={{LOCATION}}
    ```

    ```powershell
    # PowerShell
    $AZURE_ENV_NAME = "acadotnet$(Get-Random -Minimum 1000 -Maximum 9999)"
    $AZURE_LOCATION = "{{LOCATION}}"
    ```

1. Provision relevant resources onto Azure, including [Azure Container Registry (ACR)](https://learn.microsoft.com/azure/container-registry/container-registry-intro), [Azure Container App Environment (CAE)](https://learn.microsoft.com/azure/container-apps/environment), and Azure Container Apps (ACA) instances.

    ```bash
    # Bash/Zsh
    resources=$(az deployment sub create \
        -n $AZURE_ENV_NAME \
        -l $AZURE_LOCATION \
        --template-file ./bicep/main.bicep \
        --parameters @bicep/main.parameters.json \
        --parameters environmentName=$AZURE_ENV_NAME \
        --parameters location=$AZURE_LOCATION \
        --parameters eshopliteStoreExists=false)
    ```

    ```powershell
    # PowerShell
    $resources = $(az deployment sub create `
        -n $AZURE_ENV_NAME `
        -l $AZURE_LOCATION `
        --template-file ./bicep/main.bicep `
        --parameters `@bicep/main.parameters.json `
        --parameters environmentName=$AZURE_ENV_NAME `
        --parameters location=$AZURE_LOCATION `
        --parameters eshopliteStoreExists=false) | ConvertFrom-Json
    ```

1. Build the container image using Azure Container Registry (ACR).

    ```bash
    # Bash/Zsh
    ACR_NAME=$(echo $resources | jq -r ".properties.outputs.azureContainerRegistryName.value")
    az acr build \
        -r $ACR_NAME \
        -t eshoplite/store:latest \
        -f "$REPOSITORY_ROOT/ep02/Dockerfile.store" \
        "$REPOSITORY_ROOT/ep02"
    ```

    ```powershell
    # PowerShell
    $ACR_NAME = $resources.properties.outputs.azureContainerRegistryName.value
    az acr build `
        -r $ACR_NAME `
        -t eshoplite/store:latest `
        -f "$REPOSITORY_ROOT/ep02/Dockerfile.store" `
        "$REPOSITORY_ROOT/ep02"
    ```

1. Deploy the container image to ACA.

    ```bash
    # Bash/Zsh
    ACA_NAME=$(echo $resources | jq -r ".properties.outputs.azureContainerAppName.value")
    CAE_NAME=$(echo $resources | jq -r ".properties.outputs.azureContainerAppEnvironmentName.value")
    az containerapp up \
        -n $ACA_NAME \
        --environment $CAE_NAME \
        -i "$ACR_NAME.azurecr.io/eshoplite/store:latest"
    ```

    ```powershell
    # PowerShell
    $ACA_NAME = $resources.properties.outputs.azureContainerAppName.value
    $CAE_NAME = $resources.properties.outputs.azureContainerAppEnvironmentName.value
    az containerapp up `
        -n $ACA_NAME `
        --environment $CAE_NAME `
        -i "$ACR_NAME.azurecr.io/eshoplite/store:latest"
    ```

1. Open your web browser and navigate to the URL provided by the ACA instance to see the monolith app running in ACA. You can find the URL in the output of the previous command.

    ```bash
    # Bash/Zsh
    ACA_URL=$(echo $resources | jq -r ".properties.outputs.azureContainerAppUrl.value")
    echo $ACA_URL
    ```

    ```powershell
    # PowerShell
    $ACA_URL = $resources.properties.outputs.azureContainerAppUrl.value
    echo $ACA_URL
    ```

1. To clean up the resources, run the following command:

    ```bash
    az group delete -g rg-$AZURE_ENV_NAME --no-wait --yes
    ```

### Deploying the Monolith App to ACA via Azure Developer CLI

Instead of using Azure CLI, you can use Azure Developer CLI (azd) to deploy the monolith app to ACA.

1. Make sure that you're in the `ep02` directory.

    ```bash
    cd $REPOSITORY_ROOT/ep02
    ```

1. Initialize the Azure Developer CLI (azd) in the current directory.

    ```bash
    azd init
    ```

   > During initialization, you'll be asked to provide the environment name.

1. Once the initialization is complete, update the `azure.yaml` file with the Docker settings to use ACR remote build.

    ```yaml
    # azure.yaml
    name: ep02
    metadata:
      template: azd-init@1.11.0
    services:
      eshoplite-store:
        project: src/eShopLite.Store
        host: containerapp
        language: dotnet
        # 👇👇👇 Add the docker settings below
        docker:
          path: ../../Dockerfile.store
          context: ../../
          remoteBuild: true
        # 👆👆👆 Add the docker settings above
    ```

1. Because the .NET container app uses the target port number of `8080`, you need to update the `infra/resources.bicep` file to use the correct target port number.

    ```bicep
    // Update resources.bicep with the target port value
    module eshopliteStore 'br/public:avm/res/app/container-app:0.8.0' = {
      name: 'eshopliteStore'
      params: {
        name: 'eshoplite-store'
        // Change the target port value from 80 to 8080
        // ingressTargetPort: 80
        ingressTargetPort: 8080
        ...
        containers: [
          {
            ...
            env: union([
              ...
              {
                name: 'PORT'
                // Change the value from '80' to '8080'
                // value: '80'
                value: '8080'
              }
            ],
            ...
          }
        ]
        ...
      }
    }
    ```

1. Provision and deploy the monolith app to ACA.

    ```bash
    azd up
    ```

   > While executing this command, you'll be asked to provide the Azure subscription ID and location.

1. Open your web browser and navigate to the URL provided by the ACA instance on the screen to see the monolith app running in ACA.

1. To clean up the resources, run the following command:

    ```bash
    azd down --force --purge
    ```
