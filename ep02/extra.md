# 🏫EXTRA LEARNING! Monolith Applications on ACA

This section is totally optional and demonstrates a more advance technique to deploy Azure resources using [Azure CLI](https://learn.microsoft.com/cli/azure/).

## Prerequisites

You have done and completed the [Running a monolith application on ACA](README.md) content. We'll need the container image you created in that section!

### Getting the repository root

Re-initialize the variable `REPOSITORY_ROOT` in your preferred terminal.

```bash
# Bash/Zsh
REPOSITORY_ROOT=$(git rev-parse --show-toplevel)
```

```powershell
# PowerShell
$REPOSITORY_ROOT = git rev-parse --show-toplevel
```

## Deploying the monolith app to ACA via Azure CLI

This time to deploy the application to Azure Container Apps, we're going to use the Azure Command Line Interface (or Azure CLI) directly. The Azure CLI offers more granular control over Azure resources allowing you to do more fine-grained work than with azd. Of course that means you'll be doing much more work than issuing `azd init` and `azd up` commands.

1. Make sure that you're in the `ep02` directory.

    ```bash
    cd $REPOSITORY_ROOT/ep02
    ```

2. Set the environment variables `AZURE_ENV_NAME` and `AZURE_LOCATION`. Note that `{{LOCATION}}` is the Azure region where you want to deploy the resources.

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

3. Provision the relevant Azure resources, including [Azure Container Registry (ACR)](https://learn.microsoft.com/azure/container-registry/container-registry-intro), [Azure Container App Environment (CAE)](https://learn.microsoft.com/azure/container-apps/environment), and Azure Container Apps (ACA) instances.

    ```bash
    # bash/zsh
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

4. Build the container image using Azure Container Registry (ACR).

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

5. Deploy the container image to ACA.

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

6. Open your web browser and navigate to the URL provided by the ACA instance to see the monolith app running in ACA. You can find the URL in the output of the previous command.

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
