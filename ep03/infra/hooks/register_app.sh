#!/bin/bash

# Runs the register_app script
# It does the following:
# 1. Loads the azd environment variables
# 2. Logs in to the Azure CLI if not running in a GitHub Action
# 3. Registers the application on Microsoft Entra ID

set -e

# REPOSITORY_ROOT=$(git rev-parse --show-toplevel)
REPOSITORY_ROOT="$(dirname "$(realpath "$0")")/../.."

if [ -z "$GITHUB_WORKSPACE" ]; then
    # The GITHUB_WORKSPACE is not set, meaning this is not running in a GitHub Action
    source "$REPOSITORY_ROOT/infra/hooks/login.sh"
fi

# Run only if GITHUB_WORKSPACE is NOT set - this is NOT running in a GitHub Action workflow
if [ -z "$GITHUB_WORKSPACE" ]; then
    echo "Registering the application Microsoft Entra ID..."

    # Create a service principal
    appId=$(azd env get-value AZURE_PRINCIPAL_ID || echo "")
    appName="spn-$(azd env get-value AZURE_ENV_NAME)"
    if [ -z "$appId" ] || [[ "$appId" == *"not found"* ]]; then
        appId=$(az ad app list --display-name $appName --query "[].appId" -o tsv)
        if [ -z "$appId" ]; then
            appId=$(az ad app create --display-name $appName --query "appId" -o tsv)
            spnId=$(az ad sp create --id $appId --query "id" -o tsv)
        fi
    fi

    spnId=$(az ad sp list --display-name $appName --query "[].id" -o tsv)
    if [ -z "$spnId" ]; then
        spnId=$(az ad sp create --id $appId --query "id" -o tsv)
    fi

    # Set the environment variables
    azd env set AZURE_PRINCIPAL_ID $appId

    echo "...Done"
else
    echo "Skipping to register the application on Microsoft Entra ID..."
fi