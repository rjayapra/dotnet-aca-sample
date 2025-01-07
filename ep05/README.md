# EP05: Implementing CI/CD Pipeline for ACA

This sample demonstrates how to implement a Continous Integration/Continous Deployment (CI/CD) pipeline for Azure Container Apps (ACA) using Azure DevOps. We will create a GitHub action workflow to build and push the Docker images to Azure Container Registry (ACR) and deploy them to ACA. The code is based on the previous episode [EP04](../ep04/README.md).

## Prerequisites

To run this sample app, make sure you have all the [prerequisites](../README.md#prerequisites).

## Getting Started

1. Getting the Repository Root

	To simplify the copy paste of the commands that sometimes required an absolute path, we will be using the variable `REPOSITORY_ROOT` to keep the path of the root folder where you cloned/ downloaded this repository. The command `git rev-parse --show-toplevel` returns that path.

	```bash
	# Bazh/Zsh
	REPOSITORY_ROOT=$(git rev-parse --show-toplevel)
	```

	```powershell
	# PowerShell
	$REPOSITORY_ROOT = git rev-parse --show-toplevel
	```

## Quick validation, if you skiped previsous episodes

1. Validate the build the solution

	To build and run this entire solution on your local machine, run the following commands in your terminal.

    ```bash
    dotnet restore $REPOSITORY_ROOT/ep05 && dotnet build $REPOSITORY_ROOT/ep05
    ```

1. Use the `docker-compose.yml` file to create a run the container, making sure the solution works locally using containers

	> **NOTE**: Make sure to update the `appsettings.json` file in the `eShopLite.Store` project to point to the new API endpoints.
	>
	> ```json
	> {
	>   "ProductsApi": "http://products:8080",
	>   "WeatherApi": "http://weather:8080"
	> }
	> ```

    ```bash
    docker compose up --build -d
    ```

1. Open your browser and navigate to the eShopLite website at `http://localhost:5158` and navigate to the `/weather` and `/products` pages.

1. Run the following commands to stop the containers.

    ```bash
    docker compose down
    ```

## Initialize Azure Developer CLI (azd) environment

1. Make sure that you're in the `ep05` directory.

    ```bash
    cd $REPOSITORY_ROOT/ep05
    ```

1. Initialize the Azure Developer CLI (azd) in the current directory.

    ```bash
    azd init
    ```

   > During initialization, you'll be asked to provide the environment name.

## Greating a CI/CD Pipeline with AZD

1. To create the configuration file that will define the pipeline, run the following command:
    ```bash
    azd pipeline config
    ```

    > While executing this command, you'll be asked to select between GitHub or Azure DevOps the Azure subscription ID and location.

    > **NOTE**: The file `azure.yaml` won't be created under `ep05` folder. This probably cause because of the structure of the tutorial repository and will probably fix in a next release of the CLI. The `azd pipeline config` command is currently in *beta*

1. Move the `azure-dev.yml` file from `$REPOSITORY_ROOT/.github/workflows` into the `.github/workflows` folder to the `ep05` folder, and remove the empty `workflows` folder using the following commands:

    ```bash
    mkdir -p $REPOSITORY_ROOT/ep05/.github/workflows
    mv $REPOSITORY_ROOT/.github/workflows/azure-dev.yml $REPOSITORY_ROOT/ep05/.github/workflows/azure-dev.yml
    rm $REPOSITORY_ROOT/.github/workflows
    ```


