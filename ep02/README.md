# Running a monolith application on ACA

Azure Container Apps isn't limited to running microservices. In fact, if you're able to containerize a monolith application ACA makes a great service to host it on.

So let's dig in and learn how to containerize and deploy a monolith application (Blazor web app) to [Azure Container Apps (ACA)](https://learn.microsoft.com/azure/container-apps/overview).

## Prerequisites

To run the sample app, make sure you have all the [prerequisites](../README.md#prerequisites).

## Getting started

We'll be doing a lot of work from the command line in this lesson. You can use any terminal you'd like depending on your operating system.

You'll want to open the terminal and change directories to the base of where you cloned or downloaded this repository to.

### Getting the repository root

> 📝**NOTE:**
> 
> To simplify the copy paste of the commands that sometimes require an absolute path, we will be using the variable `REPOSITORY_ROOT` to keep the path of the root folder where you cloned/downloaded this repository. The command `git rev-parse --show-toplevel` returns that path.
> 

If you're running on a linux or Mac-based machine or are using bash, run the following:

```bash
# bash/zsh
REPOSITORY_ROOT=$(git rev-parse --show-toplevel)
```

Otherwise if you are using Windows and PowerShell, run this:

```powershell
# PowerShell
$REPOSITORY_ROOT = git rev-parse --show-toplevel
```

### Run the application locally

First off, let's run the application locally - without using a container, just to see what it looks like. To build and run this monolith web app on your local machine, run the following commands in your terminal.

1. Change to this directory.

    ```bash
    cd $REPOSITORY_ROOT/ep02
    ```

2. Build the app.

    ```bash
    dotnet restore && dotnet build
    ```

3. Run the app.

    ```bash
    dotnet watch run --project ./src/eShopLite.Store
    ```

When the application launches in your web browser, click on the **Products** link from the left menu and you should see a page similar to the following:

![Screenshot of the monolith application running locally showing a list of products](./images/local-app.png)

### Containerizing the Monolith App

Now that we know the app runs locally, let's build a container image of it. We can use `docker build` to do that. Run the following command.

> 🧐**INFO!**
> 
> Make sure you have Docker running

1. Build the container image using Docker CLI.

    ```bash
    docker build -f ./Dockerfile.store -t eshoplite-store:latest .
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

1. Open your web browser and navigate to `http://localhost:8080` to see the monolith app running in a container. When you click on the **Products** menu item you should see the same products as when you ran the app locally.

### Deploying the monolith application to ACA via the Azure Developer CLI (azd)

Once you're happy with the monolith app running in a container, you can deploy it to ACA through Azure Developer CLI (azd).

The [Azure Developer CLI (azd)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/overview) is an open-source tool that accelerates provisioning and deploying app resources on Azure. It provides developer-friendly commands that map to key stages in your development workflow, whether you're working in the terminal, an integrated development environment (IDE), or through CI/CD pipelines. In other words, it makes working with your application and Azure services a lot easier.

1. Make sure that you're in the `ep02` directory.

    ```bash
    cd $REPOSITORY_ROOT/ep02
    ```

1. Initialize the Azure Developer CLI (azd) with the following command:

    ```bash
    azd init
    ```

1. You'll be prompted **How do you want to initialize your app?** Choose **Use code in the current directory**. 
1. azd will scan the directory and find projects that are available to deploy. Once it completes its scan you should see output similar to the following:

    ```bash
    azd will generate the files necessary to host your app on Azure using Azure Container Apps.
    ```

  Select **Confirm and continue initializing my app**.

1. You'll now be asked to provide the environment name. This can be whatever you want and serves as a unique identifier for a specific deployment. It's also used to prefix all the Azure resources created as part of your deployment.

3. Once the initialization is complete, you'll see a new  `azure.yaml` file with the Docker settings to use ACR remote build.

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

4. Because the .NET container app uses the target port number of `8080`, you need to update the `infra/resources.bicep` file to use the correct target port number.

    ```bicep
    // Update resources.bicep with the target port value
    module eshopliteStore 'br/public:avm/res/app/container-app:0.11.0' = {
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

5. Provision and deploy the monolith app to ACA.

    ```bash
    azd up
    ```

   > While executing this command, you'll be asked to provide the Azure subscription ID and location.

6. Open your web browser and navigate to the URL provided by the ACA instance on the screen to see the monolith app running in ACA.

## Optional Learning

There multiple ways to deploy your application to Azure. Learn how to [Deploy to ACA using Azure CLI](./extra.md)

## Clean up the deployed resources

To clean up the resources, run the following command:

```bash
azd down --force --purge
```
