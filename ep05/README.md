# EP05: Implementing CI/CD Pipeline for ACA

This sample demonstrates how to put in place a Continous Integration/Continous Deployment (CI/CD) pipeline. We will create a GitHub Action workflow to build and push, and deploy the Docker images to Azure Container App. The code is based on the previous episode [EP04](../ep04/README.md).

To acheive this we will create a new GitHub repository (see [Getting Started](../ep05/README.md#getting-started)), to reflect a more realistic environment where one solution is present in a single repository. 

## Prerequisites

To run this sample app, make sure you have all the [prerequisites](../README.md#prerequisites).

## Getting Started

1. Getting the Repository Root

	To simplify the copy paste of the commands that sometimes required an absolute path, we will be using the variable `REPOSITORY_ROOT` to keep the path of the root folder where you cloned/ downloaded this repository. The command `git rev-parse --show-toplevel` returns that path.

	```bash
	# Bash/Zsh
	REPOSITORY_ROOT=$(git rev-parse --show-toplevel)
	```

	```powershell
	# PowerShell
	$REPOSITORY_ROOT = git rev-parse --show-toplevel
	```

1. Copy the Required Files

    To have a more realistic environment, we will create a new GitHub repository to reflect a more realistic environment where one solution is present in a single repository. To do this, we will copy the files from this folder `ep05` to the new folder.

    You can copy the files the way you prefer, but here is a commands to copy the files and reopen VS Code in the new folder:

    ```bash
    mkdir $REPOSITORY_ROOT/../dotnet-on-aca-ep05
    cp -r $REPOSITORY_ROOT/ep05/* $REPOSITORY_ROOT/../dotnet-on-aca-ep05
    code $REPOSITORY_ROOT/../dotnet-on-aca-ep05 -r
    ```

1. Initialize the new repository

    Let's initialize Git locally, and commit the files to the new local repository.

    ```bash
    git init
    git add .
    git commit -m "Initial ep05 commit"
    ```


## Initialize Azure Developer CLI (azd) environment

1. Initialize the Azure Developer CLI (azd) in the current directory.

    ```bash
    azd init
    ```

   > During initialization, you'll be asked to provide the environment name, remember this as it will be used to create the resource group and other resources in Azure.

## Creating a CI/CD Pipeline with AZD

1. To create the configuration file that will define the pipeline, run the following command:
    ```bash
    azd pipeline config
    ```

   While executing this command, you'll be asked a few questions:
       1. When ask, select GitHub. 
       1. Select the Azure subscription and location you want to use.
       1. Accept to add the `azure-dev.yml` file.
       1. Accept  to create git remote to GitHub, and provide a name (ex: dotnet-on-aca-ep05).
       1. The last question will be if `Would you like to commit and push your local changes to start the configured CI pipeline` reply with `y` to commit the changes.

    **NOTE**: If the deployment fails because .NET SDK 9 is not installed, you can edit the `azure-dev.yml`. Add the a step between `Checkout` and `Install azd` to install the .NET SDK 9.0.

    ```yaml
        steps:
        - name: Checkout
            uses: actions/checkout@v4

        // 👇👇👇 Add the step Setup .NET below
        - name: Setup .NET
            uses: actions/setup-dotnet@v4
            with:
            dotnet-version: 9.0.x
        // 👆👆👆 Add the step Setup .NET above

        - name: Install azd
            uses: Azure/setup-azd@v1.0.0
    ```

## Examine the GitHub Actions Workflow

The deployment will take a few minutes. You can monitor the pipeline status in the tab `Actions` in your Github page. The URL should have been printed in the console after the `azd pipeline config` command. (ex: https://github.com/FBoucher/dotnet-on-aca-ep05/actions) 

While it's deploying let's examine the `.github/workflows/azure-dev.yml` file in your code editor.

1. When the workflow will be triggered

    The workflow will be triggered when a push is made to the `main` branch. As we can see in the `on` section of the workflow file:

    ```yaml
    on:
      push:
        # Run when commits are pushed to mainline branch (main or master)
        # Set this to the mainline branch you are using
        branches:
          - main
    ```

2. How the permission works

    The workflow uses the `Azure/setup-azd@v1.0.0` action to authenticate with Azure. The action uses the `AZD_INITIAL_ENVIRONMENT_CONFIG` secret that was created in the previous step with the `azd pipeline config` command.
    The secret is saved in the repository settings under `Settings` -> `Secrets and variables` -> `Actions`. You won't be able to see the value of the secret, but you can update it if needed.

3. What the workflow does

    The workflow has the following steps:

    - `Checkout`: This step checks out the code from the repository.
    - (optionally) `Setup .NET`: This step installs the .NET SDK 9.0.
    - `Install azd`: This step installs the Azure Developer CLI (azd) on the runner.
    - `Log in with Azure (Federated Credentials)`: This step logs in to the Azure subscription.
    - `Provision Infrastructure`: This step provisions the infrastructure using the Bicep file.
    - `Deploy Application`: This step deploys the microservices to Azure Container Apps. like we did in the previous episode.


## Look at the deployed resources
1. Open your web browser and navigate to the Azure Portal (https://portal.azure.com/). Open the resource group with the name matching `rg` + the env name used with azd init (ex: rg-ep05). 
1. Open the `eshoplite-store` Container App and click on the `Application Url`, at the top right of the page, to see the deployed store.

## Update the code and see the changes

1. Open the `src\eShopLite.Store\Components\Pages\Home.razor` file, and change the welcome message to something else.
1. Commit and push the changes to the `main` branch.

    ```bash
    git add .
    git commit -m "Update welcome message"
    git push
    ```

1. Open the `Actions` tab in your GitHub repository to see the workflow running. Once the workflow is completed, refresh the store page to see the changes.

## Clean up the deployed resources

To clean up the resources, run the following command:

```bash
azd down --force --purge
```

## Clean up the GitHub repository

To clean up the GitHub repository, go to the repository settings and scroll down to the `Danger Zone` section. Click on the `Delete this repository` button and confirm the deletion.






