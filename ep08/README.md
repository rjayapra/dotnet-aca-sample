# EP08: Introduction of .NET Aspire for Easy Orchestration

This sample app demonstrates how to easily orchestrate MSA apps and deploy them to [Azure Container Apps (ACA)](https://learn.microsoft.com/azure/container-apps/overview), using [.NET Aspire](https://aka.ms/dotnet-aspire).

## Prerequisites

To run this sample app, make sure you have all the [prerequisites](../README.md#prerequisites).

## Quick tour of the solution

All the apps are copied from [`ep04`](../ep04/) except Dockerfiles and Docker Compose files. The solution contains the following projects:

- `eShopLite.Store`: The frontend web app using Blazor.
- `eShopLite.Products`: The backend API app that takes care of products with [SQLite](https://www.sqlite.org/).
- `eShopLite.Weather`: The backend API app that looks after the weather.
- `eShopLite.DataEntities`: The class library that contains data entities consumed by all the other apps.

## Getting Started

During this episode, we will replace the existing SQLite database with a containerized [PostgreSQL](https://www.postgresql.org/) one. We will also introduce .NET Aspire to orchestrate the MSA apps. You will start from the `ep08/1_start` directory and see the final result from the `ep08/2_complete` directory.

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

1. Make sure that you're in the `ep08/1_start` directory.

    ```bash
    cd $REPOSITORY_ROOT/ep08/1_start
    ```

1. Build the solution.

    ```bash
    dotnet restore && dotnet build
    ```

1. Open three terminals. Each terminal runs each project respectively.

    ```bash
    # Terminal 1
    cd $REPOSITORY_ROOT/ep08/1_start
    dotnet watch run --project ./src/eShopLite.Products
    ```

    ```bash
    # Terminal 2
    cd $REPOSITORY_ROOT/ep08/1_start
    dotnet watch run --project ./src/eShopLite.Weather
    ```

    ```bash
    # Terminal 3
    cd $REPOSITORY_ROOT/ep08/1_start
    dotnet watch run --project ./src/eShopLite.Store
    ```

   > **NOTE**: If new terminals don't recognize `$REPOSITORY_ROOT` variable, run the command again to get the path.

1. Open a browser and navigate to `https://localhost:5158` to see the app running. Then navigate to `/weather` and `/products` to see both pages are properly working.

1. To stop the apps, press `Ctrl+C` in each terminal.

### Add .NET Aspire to the Solution

To orchestrate all the apps without Dockerfiles or Docker Compose files, Let's add .NET Aspire to the solution.

1. Make sure that you're in the `ep08/1_start` directory.

    ```bash
    cd $REPOSITORY_ROOT/ep08/1_start
    ```

1. Add .NET Aspire AppHost to the solution.

    ```bash
    dotnet new aspire-apphost -n eShopLite.AppHost -o src/eShopLite.AppHost
    ```

1. Add .NET Aspire ServiceDefault to the solution.

    ```bash
    dotnet new aspire-servicedefaults -n eShopLite.ServiceDefaults -o src/eShopLite.ServiceDefaults
    ```

1. Add both projects to the solution.

    ```bash
    dotnet sln add ./src/eShopLite.AppHost
    dotnet sln add ./src/eShopLite.ServiceDefaults
    ```





