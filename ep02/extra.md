# EP02: Monolith App on ACA - EXTRA

This section is totally optional and demonstrates a more advance technique to deploy Azure resources using [Azure CLI](https://learn.microsoft.com/cli/azure/).

## Prerequisites

You have done and completed the [ep02](README.md) content.

### Getting the repository root

If you planned to use PowerShell you will need to initialize the variable `REPOSITORY_ROOT` in a PowerShell terminal, or you can continue using bash.

```bash
# Bazh/Zsh
REPOSITORY_ROOT=$(git rev-parse --show-toplevel)
```

```powershell
# PowerShell
$REPOSITORY_ROOT = git rev-parse --show-toplevel
```

## Deploying the Monolith App to ACA via Azure CLI

Once you're happy with the monolith app running in a container, you can deploy it to ACA.

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


## Clean up the deployed resources

1. To clean up the resources, run the following command:

    ```bash
    az group delete -g rg-$AZURE_ENV_NAME --no-wait --yes
    ```
