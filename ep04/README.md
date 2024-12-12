# EP04: Transforming Monolith App to MSA

There is 2 folders in this module:
- `start`: This is the monolith app before the transformation
- `final`: this is the microservice app after the transformation


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

Make sure the httpClient in `eShopLite.Store/Program.cs` look like this to execute the solution locally.

```csharp
builder.Services.AddHttpClient<ProductApiClient>(client =>
{
    client.BaseAddress = new("http://localhot:5258");
});
builder.Services.AddHttpClient<WeatherApiClient>(client =>
{
    client.BaseAddress = new("http://localhot:5151");
});
```




## Execute the solution with Docker

Update the httpClient in `eShopLite.Store/Program.cs` to point to the new API endpoints:

```csharp
builder.Services.AddHttpClient<ProductApiClient>(client =>
{
    client.BaseAddress = new("http://products:8080");
});
builder.Services.AddHttpClient<WeatherApiClient>(client =>
{
    client.BaseAddress = new("http://weather:8080");
});
```

**Build** all the container with the following commands:

```bash
docker build -t eshoplite-weather:latest  -f .\Dockerfile.weather . 

docker build -t eshoplite-products:latest  -f .\Dockerfile.products . 

docker build -t eshoplite-store:latest  -f .\Dockerfile.store . 
```

To run the entire solution locally use the following command:

```bash
docker compose -f .\docker-compose.yml up 
```

## Deploying to Azure

```bash
azd init
```

Once initialized update the services `src/azure.yaml`:

```
services:
    eshoplite-products:
        project: src/eShopLite.Products
        host: containerapp
        language: dotnet
        docker:
            path: src/Dockerfile.products
            context: ./
            remoteBuild: true
    eshoplite-store:
        project: src/eShopLite.Store
        host: containerapp
        language: dotnet
        docker:
            path: src/Dockerfile.store
            context: ./
            remoteBuild: true
    eshoplite-weather:
        project: src/eShopLite.Weather
        host: containerapp
        language: dotnet
        docker:
            path: src/Dockerfile.weather
            context: ./
            remoteBuild: true
```


THen should be able to deploy the solution with the following command:
```bash
azd up
```
