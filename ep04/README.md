# EP04: Transforming Monolith App to MSA

### Getting the repository root

```bash
# Bazh/Zsh
REPOSITORY_ROOT=$(git rev-parse --show-toplevel)
```
or
```powershell
# PowerShell
$REPOSITORY_ROOT = git rev-parse --show-toplevel
```

## Quick tour of the splitted solution


- We will break-down the current project into 3 projects:
  - `eShopLite.Store`: It's as the same name as in the previous monolith, but kept only the frontend components.
  - `eShopLite.Products`: New web API project where the product API and dabases were moved
  - `eShopLite.Weather`: New web API project where the Weather API were moved
  - `eShopLite.DataEntities`: New class library project where the data entities
  

To execute the solution locally you need to start all those project independantly. We created a Launch Profile in VSCode that does just that. Open the folder `ep4/scr` in VSCode and run the `Run all` profile, In the Run & Debug panel.

.NET will launch all the project on localhost using different ports. Make validate the values of `ProductsApi` and `WeatherApi` in `appsettings.json` file look like this to execute the solution locally.

```json
"ProductsApi": "http://localhot:5258",
"WeatherApi": "http://localhot:5151"
```


## Execute the solution with Docker

Just like we learn previously we can containerize the each project in it's own container. The main difference is that if you look to `Dockerfile.products` and `Dockerfile.store` you will notice that in the first section of the file we are copying the `eShopLite.DataEntities` project to the container. This is because the `eShopLite.Products` and `eShopLite.Store` projects depend on the `eShopLite.DataEntities` project.

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS build
COPY ./src/eShopLite.Products /source/eShopLite.Products
COPY ./src/eShopLite.DataEntities /source/eShopLite.DataEntities
```

You could build each container individually with the following commands:

```bash
docker build -t eshoplite-weather:latest  -f .\Dockerfile.weather . 
docker build -t eshoplite-products:latest  -f .\Dockerfile.products . 
docker build -t eshoplite-store:latest  -f .\Dockerfile.store . 
```

Then run them with the following commands:

```bash
docker run -p 5151:8080 --name eshoplite-weather eshoplite-weather:latest
...
```

But there is a better way to do this. We can use Docker Compose to orchestrate the containers. Looking at the `docker-compose.yml` file you will see that we are defining the services for each project. We also created **links** between the services to make it easier for eshoplite-store reach the other services.

The next step is to update the `appsettings.json` file in the `eShopLite.Store` project to point to the new API endpoints:

```json
"ProductsApi": "http://products:8080",
"WeatherApi": "http://weather:8080"
```

To run the entire solution locally using container execute the following command:

```bash
docker compose -f .\docker-compose.yml up --build -d
```

Using the command `docker ps` you will see the 3 containers up and running. You can navigate to the eShotLite website from your bowser at the URL `http://localhost:5158`.

## Stopping the solution

To stop the solution execute the docker compose down command:

```bash
docker compose -f .\docker-compose.yml down
```


## Deploying to Azure

Initialize the Azure Developer CLI (azd) in the current directory.

```bash
azd init
```

Once the initialization is complete, update the `azure.yaml` file with the Docker settings to use ACR remote build.

```
services:
    eshoplite-products:
        project: src/eShopLite.Products
        host: containerapp
        language: dotnet
        docker:
            path: ../../Dockerfile.products
            context: ../../
            remoteBuild: true
    eshoplite-store:
        project: src/eShopLite.Store
        host: containerapp
        language: dotnet
        docker:
            path: ../../Dockerfile.store
            context: ../../
            remoteBuild: true
    eshoplite-weather:
        project: src/eShopLite.Weather
        host: containerapp
        language: dotnet
        docker:
            path: ../../Dockerfile.weather
            context: ../../
            remoteBuild: true
```


Just like before, you need to update the `infra/resources.bicep` file to use the correct target port number. Because the .NET container app uses the target port number of `8080` instead of `80`. You will need to update the values for the 3 services.

```yaml
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


Then provision and deploy the solution to Azure Container Apps with the Azure Developer CLI command:
```bash
azd up
```



To clean up the resources, run the following command:

```bash
azd down --force --purge
```