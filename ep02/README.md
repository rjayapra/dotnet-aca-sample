# EP02: Monolith App on ACA

This sample app demonstrates how to containerize and deploy a monolith app (Blazor web app) to [Azure Container Apps (ACA)](https://learn.microsoft.com/en-us/azure/container-apps/overview).

## Prerequisites

To run this sample app, make sure you have all the [prerequisites](../README.md#prerequisites).

## Getting Started

### Getting the repository root

To simplify the copy paste of the commands that sometimes required an absolute path, we will be using the variable `REPOSITORY_ROOT` to keep the path of the root folder where you cloned/ downloaded this repository. The command `git rev-parse --show-toplevel` returns that path.

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


### Deploying the Monolith App to ACA via Azure Developer CLI (AZD)

Instead of using Azure CLI, you can use Azure Developer CLI (AZD) to deploy the monolith app to ACA.

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

### Optional Learning

There multiple ways to deploy your application to Azure. Learn how to [Deploy to ACA using Azure CLI](./extra.md)

## Clean up the deployed resources

To clean up the resources, run the following command:

```bash
azd down --force --purge
```
