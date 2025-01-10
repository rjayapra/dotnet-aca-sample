# EP07: Monitoring ACA

Azure Container Apps provides several built-in observability features that together give you a great view of your container app’s health. In this episode, we will do a quick tour of the monitoring capabilities of Azure Container Apps.

## Getting Started

You can reuse the code and deployed solution from the previous episode (ep04, ep05, ep06). If you deleted the resources, you can redeploy the solution using the following steps.

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

1. Move to the `ep07` directory.

    ```bash
    cd $REPOSITORY_ROOT/ep07
    ```

1. Initialize the Azure Developer CLI (azd) in the current directory.

    ```bash
    azd init
    ```

1. Provision and deploy the microservice apps to ACA.

    ```bash
    azd up
    ```

1. Open the browser and navigate to the deployed app to validate that it's working as expected.
   > **Note**: You may feel some delay in the response of the Product service, it's unpurposely added to simulate a slow response.
 

## Exploring the Monitoring Capabilities in Azure Container Apps

Azure Container Apps provides several built-in observability features that are available directly from the Azure portal. Let's explore them.

1. Open the Azure portal and navigate to the Azure Container Apps resource.
1. In the left-hand menu, under Monitoring, you will find the following options:
	- **Metrics**: View metrics for your container app.
	- **Logs**: View logs for your container app.
	- **Alerts**: Set up alerts for your container app.
	- **Diagnostics settings**: Configure diagnostic settings for your container app.
	- **Activity log**: View the activity log for your container app.
	- **Insights**: View insights for your container app.

