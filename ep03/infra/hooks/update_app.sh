#!/bin/bash

# Runs the update_app script
# It does the following:
# 1. Loads the azd environment variables
# 2. Logs in to the Azure CLI if not running in a GitHub Action
# 3. Updates EasyAuth settings for Azure Container App
# 4. Update the application on Microsoft Entra ID

set -e

# REPOSITORY_ROOT=$(git rev-parse --show-toplevel)
REPOSITORY_ROOT="$(dirname $(realpath $0))/../.."

if [[ -z "$GITHUB_WORKSPACE" ]]; then
    # The GITHUB_WORKSPACE is not set, meaning this is not running in a GitHub Action
    source "$REPOSITORY_ROOT/infra/hooks/login.sh"
fi

# Run only if GITHUB_WORKSPACE is NOT set
if [[ -z "$GITHUB_WORKSPACE" ]]; then
    echo "Updating the EasyAuth settings..."

    CLIENT_ID="$(azd env get-value AZURE_PRINCIPAL_ID)"
    TENANT_ID="$(az account show --query "tenantId" -o tsv)"

    RESOURCE_GROUP="rg-$(azd env get-value AZURE_ENV_NAME)"

    CONTAINERAPP_NAME="$(azd env get-value AZURE_RESOURCE_CONTAINERAPP_NAME)"
    CONTAINERAPP_URL="$(azd env get-value AZURE_RESOURCE_CONTAINERAPP_URL)"

    # Get a service principal
    appId="$CLIENT_ID"
    objectId=$(az ad app show --id "$appId" --query "id" -o tsv)

    # Add client secret to the app
    clientSecret=$(az ad app credential reset --id "$appId" --display-name "default" --query "password" -o tsv)

    # Update EasyAuth settings for Azure Container App
    echo "...Updating Azure Container Apps..."

    __=$(az containerapp secret set -g "$RESOURCE_GROUP" -n "$CONTAINERAPP_NAME" --secrets microsoft-provider-authentication-secret="$clientSecret")
    __=$(az containerapp update -g "$RESOURCE_GROUP" -n "$CONTAINERAPP_NAME" --set-env-vars MICROSOFT_PROVIDER_AUTHENTICATION_SECRET="$clientSecret")

    __=$(az containerapp auth microsoft update -g "$RESOURCE_GROUP" -n "$CONTAINERAPP_NAME" --client-id "$CLIENT_ID" --client-secret "$clientSecret" --tenant-id "$TENANT_ID" -y)
    __=$(az containerapp auth update -g "$RESOURCE_GROUP" -n "$CONTAINERAPP_NAME" --action AllowAnonymous --redirect-provider AzureActiveDirectory --require-https true -y)

    echo "...Done"

    echo "Updating the application on Microsoft Entra ID..."

    # Add identifier URIs to the app
    echo "...Adding Identifier URIs..."

    __=$(az ad app update --id "$appId" --identifier-uris "api://$appId")

    # Add API scopes to the app
    echo "...Adding API scopes..."

    app=$(az ad app show --id "$appId" -o json)
    scope=$(echo "$app" | jq '.api.oauth2PermissionScopes[0]')
    if [[ "$scope" != "null" ]]; then
        scope=$(echo "$scope" | jq '.isEnabled = false')
        api=$(jq -n --argjson scope "$scope" '{requestedAccessTokenVersion: 2, oauth2PermissionScopes: [$scope]}')
        __=$(az ad app update --id "$appId" --set api="$api")

        api=$(jq -n '{requestedAccessTokenVersion: 2, oauth2PermissionScopes: []}')
        __=$(az ad app update --id "$appId" --set api="$api")
    fi

    api=$(jq -n \
        '{
          requestedAccessTokenVersion: 2,
          oauth2PermissionScopes: [
            { id: "'$(uuidgen)'",
              type: "User",
              value: "user_impersonation",
              adminConsentDisplayName: "Access as the signed-in user",
              adminConsentDescription: "Access as the signed-in user",
              isEnabled: true
            }
          ]
        }')
    __=$(az ad app update --id "$appId" --set api="$api")

    # Add web settings to the app
    echo "...Adding web settings..."

    web=$(jq -n --arg containerAppUrl "$CONTAINERAPP_URL" \
        '{
          redirectUris: [
            $containerAppUrl + "/.auth/login/aad/callback"
          ],
          implicitGrantSettings: {
            enableIdTokenIssuance: true
          }
        }')
    __=$(az ad app update --id "$appId" --set web="$web")

    # Add API permissions to the app
    echo "...Adding API permissions..."

    resourceAccess=$(jq -n '[
        {id: "06da0dbc-49e2-44d2-8312-53f166ab848a", type: "Scope"},
        {id: "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0", type: "Scope"},
        {id: "5f8c59db-677d-491f-a6b8-5f174b11ec1d", type: "Scope"},
        {id: "7427e0e9-2fba-42fe-b0c0-848c9e6a8182", type: "Scope"},
        {id: "37f7f235-527c-4136-accd-4a02d197296e", type: "Scope"},
        {id: "14dad69e-099b-42c9-810b-d002981feec1", type: "Scope"},
        {id: "a154be20-db9c-4678-8ab7-66f6cc099a59", type: "Scope"}
    ]')
    requiredResourceAccess=$(jq -n --argjson resourceAccess "$resourceAccess" \
        '[
          { resourceAppId: "00000003-0000-0000-c000-000000000000",
            resourceAccess: $resourceAccess
          }
        ]')
    az rest -m PATCH --uri "https://graph.microsoft.com/v1.0/applications/$objectId" --headers Content-Type=application/json --body "{ \"requiredResourceAccess\": $requiredResourceAccess }"

    # Add optional claims to the app
    echo "...Adding optional claims..."

    groupClaim=$(jq -n \
        '{
          additionalProperties: [
            "emit_as_roles"
          ],
          essential: false,
          name: "groups"
        }')
    optionalClaims=$(jq -n --argjson groupClaim "$groupClaim" \
        '{
          accessToken: [
            $groupClaim
          ],
          idToken: [
            $groupClaim
          ],
          saml2Token: [
            $groupClaim
          ]
        }')
    __=$(az ad app update --id "$appId" --set optionalClaims="$optionalClaims")
    __=$(az ad app update --id "$appId" --set groupMembershipClaims="SecurityGroup")

    echo "...Done"
else
    echo "Skipping to update the application on Microsoft Entra ID..."
fi
