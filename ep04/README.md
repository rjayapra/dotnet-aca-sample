# EP04: Transforming Monolith App to MSA

This sample app demonstrates how to transform a monolith app (Blazor web app) to microservice architecture (MSA) and deploy them to [Azure Container Apps (ACA)](https://learn.microsoft.com/azure/container-apps/overview).

## Prerequisites

To run this sample app, make sure you have all the [prerequisites](../README.md#prerequisites).

## Quick tour of the split solution

We will break-down the current project into four smaller projects:

- `eShopLite.Store`: It's as the same name as in the previous monolith, but kept only the frontend components.
- `eShopLite.Products`: New web API project where the product API and databases are hosted
- `eShopLite.Weather`: New web API project where the Weather API is hosted
- `eShopLite.DataEntities`: New class library project for the data entities

## Getting Started

### Getting the Repository Root

To simplify the copy paste of the commands that sometimes required an absolute path, we will be using the variable `REPOSITORY_ROOT` to keep the path of the root folder where you cloned/ downloaded this repository. The command `git rev-parse --show-toplevel` returns that path.

```bash
# Bazh/Zsh
REPOSITORY_ROOT=$(git rev-parse --show-toplevel)
```

```powershell
# PowerShell
$REPOSITORY_ROOT = git rev-parse --show-toplevel
```

### Running the Microservice Apps Locally

To build and run this entire solution on your local machine, run the following commands in your terminal.

1. Build the solution.

    ```bash
    dotnet restore $REPOSITORY_ROOT/ep04 && dotnet build $REPOSITORY_ROOT/ep04
    ```

1. Open three terminals. Each terminal runs each project respectively.

    ```bash
    # Terminal 1
    cd $REPOSITORY_ROOT/ep04
    dotnet watch run --project ./src/eShopLite.Products
    ```

    ```bash
    # Terminal 2
    cd $REPOSITORY_ROOT/ep04
    dotnet watch run --project ./src/eShopLite.Weather
    ```

    ```bash
    # Terminal 3
    cd $REPOSITORY_ROOT/ep04
    dotnet watch run --project ./src/eShopLite.Store
    ```

   > **NOTE**: If new terminals don't recognize `$REPOSITORY_ROOT` variable, run the command again to get the path.

1. Alternatively, open your VS code at `ep04` and run the `Run all` profile, in the Run & Debug panel.

### Containerizing Microservice Apps

Just like you learnt previously, you can containerize the each project in its own container. You have `Dockerfile.products`, `Dockerfile.weather` and `Dockerfile.store`. Each `Dockerfile` doesn't only copy its own project but also copies the `eShopLite.DataEntities` project to the container. This is because each `eShopLite.Products`, `eShopLite.Weather` and `eShopLite.Store` project depends on the `eShopLite.DataEntities` project.

Here's the sample of the `Dockerfile.products` file:

```dockerfile
...

FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS build

COPY ./src/eShopLite.Products /source/eShopLite.Products
COPY ./src/eShopLite.DataEntities /source/eShopLite.DataEntities

...
```

1. Move to the `ep04` directory.

    ```bash
    cd $REPOSITORY_ROOT/ep04
    ```

1. Open `src/eShopLite.Store/appsettings.json` and update the `ProductsApi` and `WeatherApi` URLs to point to the new API endpoints. The URLs should be as follows:

    ```json
    {
      "ProductsApi": "http://products:8080",
      "WeatherApi": "http://weather:8080"
    }
    ```

1. Build the container image using Docker CLI.

    ```bash
    docker build -t eshoplite-products:latest  -f ./Dockerfile.products .
    docker build -t eshoplite-weather:latest  -f ./Dockerfile.weather .
    docker build -t eshoplite-store:latest  -f ./Dockerfile.store .
    ```

### Running the Microservice Apps in Containers

Once you have all the container images of for the microservice apps, you can run them in containers.

1. Create a network for the containers to communicate with each other.

    ```bash
    docker network create eshop-net
    ```

1. Run the following commands to run the microservice apps in containers.

    ```bash
    docker run -d -p 5228:8080 --network eshop-net --network-alias products --name products eshoplite-products:latest
    docker run -d -p 5151:8080 --network eshop-net --network-alias weather --name weather eshoplite-weather:latest
    docker run -d -p 5158:8080 --network eshop-net --network-alias store --name store eshoplite-store:latest
    ```

1. Open your browser and navigate to the eShopLite website at `http://localhost:5158` and navigate to the `/weather` and `/products` pages.

1. Run the following commands to stop the containers.

    ```bash
    docker stop store weather products
    docker rm store weather products --force
    docker rmi eshoplite-store:latest eshoplite-weather:latest eshoplite-products:latest --force
    docker network rm eshop-net --force
    ```

1. Alternatively, you can use Docker Compose to orchestrate the containers. Looking at the `docker-compose.yml` file you will see that we are defining the services for each project. We also created **links** between the services to make it easier for eshoplite-store reach the other services.

    ```bash
    docker compose up --build -d
    ```

   > **NOTE**: Make sure to update the `appsettings.json` file in the `eShopLite.Store` project to point to the new API endpoints.
   >
   > ```json
   > {
   >   "ProductsApi": "http://products:8080",
   >   "WeatherApi": "http://weather:8080"
   > }
   > ```

1. Open your browser and navigate to the eShopLite website at `http://localhost:5158` and navigate to the `/weather` and `/products` pages.

1. Run the following commands to stop the containers.

    ```bash
    docker compose down --rmi local
    ```

### Deploying the Microservice Apps to ACA via Azure Developer CLI (AZD)

Once you're happy with the microservice apps running in a container, you can deploy it to ACA through Azure Developer CLI (AZD).

1. Make sure that you're in the `ep04` directory.

    ```bash
    cd $REPOSITORY_ROOT/ep04
    ```

1. Initialize the Azure Developer CLI (azd) in the current directory.

    ```bash
    azd init
    ```

   > During initialization, you'll be asked to provide the environment name.

1. Once the initialization is complete, update the `azure.yaml` file with the Docker settings to use ACR remote build.

    ```yaml
    name: ep04
    metadata:
      template: azd-init@1.11.0
    services:
      eshoplite-products:
        project: src/eShopLite.Products
        host: containerapp
        language: dotnet
        # 👇👇👇 Add the docker settings below
        docker:
          path: ../../Dockerfile.products
          context: ../../
          remoteBuild: true
        # 👆👆👆 Add the docker settings above
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
      eshoplite-weather:
        project: src/eShopLite.Weather
        host: containerapp
        language: dotnet
        # 👇👇👇 Add the docker settings below
        docker:
          path: ../../Dockerfile.weather
          context: ../../
          remoteBuild: true
        # 👆👆👆 Add the docker settings above
    ```

1. Because the .NET container app uses the target port number of `8080`, you need to update the `infra/resources.bicep` file to use the correct target port number. This time, you have three ACA instances: `eshoplite-products`, `eshoplite-store` and `eshoplite-weather`. Therefore, you will have to update three locations of the `ingressTargetPort` and `PORT` values.

    ```bicep
    ...
     // ingressTargetPort: 80
     ingressTargetPort: 8080
    ...
        {
            name: 'PORT'
            // value: '80'
            value: '8080'
        }
    ```

1. Also the Store app should be able to discover both Products and Weather APIs. Therefore, also update the `infra/resources.bicep` for the service discovery.

    ```bicep
    module eshopliteStore 'br/public:avm/res/app/container-app:0.8.0' = {
      name: 'eshopliteStore'
      ...
            env: union([
              {
                name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
                value: monitoring.outputs.applicationInsightsConnectionString
              }
              {
                name: 'AZURE_CLIENT_ID'
                value: eshopliteStoreIdentity.outputs.clientId
              }
              {
                name: 'PORT'
                value: '8080'
              }
              // 👇👇👇 Add the environment variables below
              {
                name: 'ProductsApi'
                value: 'https://${eshopliteProducts.outputs.fqdn}'
              }
              {
                name: 'WeatherApi'
                value: 'https://${eshopliteWeather.outputs.fqdn}'
              }
              // 👆👆👆 Add the environment variables above
            ],
      ...
    }
    ```

1. Provision and deploy the microservice apps to ACA.

    ```bash
    azd up
    ```

   > While executing this command, you'll be asked to provide the Azure subscription ID and location.

1. Open your web browser and navigate to the URLs provided by the ACA instances on the screen to see the microservice apps running in ACA.

## Clean up the deployed resources

To clean up the resources, run the following command:

```bash
azd down --force --purge
```