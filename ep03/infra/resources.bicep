@description('The location used for all deployed resources')
param location string = resourceGroup().location

@description('Tags that will be applied to all resources')
param tags object = {}

param eshopLiteStoreContainerappExists bool
@secure()
param eshopLiteStoreContainerappDefinition object

@description('Id of the user or app to assign application roles')
param principalId string

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = uniqueString(subscription().id, resourceGroup().id, location)

// Monitor application with Azure Monitor
module monitoring 'br/public:avm/ptn/azd/monitoring:0.1.0' = {
  name: 'monitoring'
  params: {
    logAnalyticsName: '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    applicationInsightsName: '${abbrs.insightsComponents}${resourceToken}'
    applicationInsightsDashboardName: '${abbrs.portalDashboards}${resourceToken}'
    location: location
    tags: tags
  }
}

// Container registry
module containerRegistry 'br/public:avm/res/container-registry/registry:0.6.0' = {
  name: 'registry'
  params: {
    name: '${abbrs.containerRegistryRegistries}${resourceToken}'
    location: location
    acrAdminUserEnabled: true
    tags: tags
    exportPolicyStatus: 'enabled'
    publicNetworkAccess: 'Enabled'
    roleAssignments:[
      {
        principalId: eshopLiteStoreContainerappIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
      }
    ]
  }
}

// Container apps environment
module containerAppsEnvironment 'br/public:avm/res/app/managed-environment:0.8.1' = {
  name: 'container-apps-environment'
  params: {
    logAnalyticsWorkspaceResourceId: monitoring.outputs.logAnalyticsWorkspaceResourceId
    name: '${abbrs.appManagedEnvironments}${resourceToken}'
    location: location
    zoneRedundant: false
  }
}

module eshopLiteStoreContainerappIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.0' = {
  name: 'eshopLiteStoreContainerappidentity'
  params: {
    name: '${abbrs.managedIdentityUserAssignedIdentities}eshopLiteStoreContainerapp-${resourceToken}'
    location: location
  }
}

module eshopLiteStoreContainerappFetchLatestImage './modules/fetch-container-image.bicep' = {
  name: 'eshopLiteStoreContainerapp-fetch-image'
  params: {
    exists: eshopLiteStoreContainerappExists
    name: 'eshopLiteStore-containerapp'
  }
}

var eshopLiteStoreContainerappAppSettingsArray = filter(array(eshopLiteStoreContainerappDefinition.settings), i => i.name != '')
var eshopLiteStoreContainerappSecrets = map(filter(eshopLiteStoreContainerappAppSettingsArray, i => i.?secret != null), i => {
  name: i.name
  value: i.value
  secretRef: i.?secretRef ?? take(replace(replace(toLower(i.name), '_', '-'), '.', '-'), 32)
})
var eshopLiteStoreContainerappEnv = map(filter(eshopLiteStoreContainerappAppSettingsArray, i => i.?secret == null), i => {
  name: i.name
  value: i.value
})

module eshopLiteStoreContainerapp 'br/public:avm/res/app/container-app:0.11.0' = {
  name: 'eshopLiteStoreContainerapp'
  params: {
    name: 'eshoplitestore-containerapp'
    ingressTargetPort: 8080
    scaleMinReplicas: 1
    scaleMaxReplicas: 10
    secrets: {
      secureList: union([
      ],
      map(eshopLiteStoreContainerappSecrets, secret => {
        name: secret.secretRef
        value: secret.value
      }))
    }
    containers: [
      {
        image: eshopLiteStoreContainerappFetchLatestImage.outputs.?containers[?0].?image ?? 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
        name: 'main'
        resources: {
          cpu: json('0.5')
          memory: '1.0Gi'
        }
        env: union([
          {
            name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
            value: monitoring.outputs.applicationInsightsConnectionString
          }
          {
            name: 'AZURE_CLIENT_ID'
            value: eshopLiteStoreContainerappIdentity.outputs.clientId
          }
          {
            name: 'PORT'
            value: '8080'
          }
        ],
        eshopLiteStoreContainerappEnv,
        map(eshopLiteStoreContainerappSecrets, secret => {
            name: secret.name
            secretRef: secret.secretRef
        }))
      }
    ]
    managedIdentities:{
      systemAssigned: false
      userAssignedResourceIds: [eshopLiteStoreContainerappIdentity.outputs.resourceId]
    }
    registries:[
      {
        server: containerRegistry.outputs.loginServer
        identity: eshopLiteStoreContainerappIdentity.outputs.resourceId
      }
    ]
    environmentResourceId: containerAppsEnvironment.outputs.resourceId
    location: location
    tags: union(tags, { 'azd-service-name': 'eshoplitestore-containerapp' })
  }
}

// Create a keyvault to store secrets
module keyVault 'br/public:avm/res/key-vault/vault:0.11.1' = {
  name: 'keyvault'
  params: {
    name: '${abbrs.keyVaultVaults}${resourceToken}'
    location: location
    tags: tags
    enableRbacAuthorization: false
    accessPolicies: [
      {
        objectId: principalId
        permissions: {
          secrets: [ 'get', 'list' ]
        }
      }
      {
        objectId: eshopLiteStoreContainerappIdentity.outputs.principalId
        permissions: {
          secrets: [ 'get', 'list' ]
        }
      }
    ]
    secrets: [
    ]
  }
}

output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.outputs.loginServer
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.uri
output AZURE_KEY_VAULT_NAME string = keyVault.outputs.name

output AZURE_RESOURCE_CONTAINERAPP_ID string = eshopLiteStoreContainerapp.outputs.resourceId
output AZURE_RESOURCE_CONTAINERAPP_NAME string = eshopLiteStoreContainerapp.outputs.name
output AZURE_RESOURCE_CONTAINERAPP_URL string = 'https://${eshopLiteStoreContainerapp.outputs.fqdn}'
