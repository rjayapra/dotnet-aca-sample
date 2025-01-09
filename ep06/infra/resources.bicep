@description('The location used for all deployed resources')
param location string = resourceGroup().location

@description('Tags that will be applied to all resources')
param tags object = {}


param eshopliteProductsExists bool
@secure()
param eshopliteProductsDefinition object
param eshopliteStoreExists bool
@secure()
param eshopliteStoreDefinition object
param eshopliteWeatherExists bool
@secure()
param eshopliteWeatherDefinition object

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
module containerRegistry 'br/public:avm/res/container-registry/registry:0.1.1' = {
  name: 'registry'
  params: {
    name: '${abbrs.containerRegistryRegistries}${resourceToken}'
    location: location
    acrAdminUserEnabled: true
    tags: tags
    publicNetworkAccess: 'Enabled'
    roleAssignments:[
      {
        principalId: eshopliteProductsIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
      }
      {
        principalId: eshopliteStoreIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
      }
      {
        principalId: eshopliteWeatherIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
      }
    ]
  }
}

// Container apps environment
module containerAppsEnvironment 'br/public:avm/res/app/managed-environment:0.4.5' = {
  name: 'container-apps-environment'
  params: {
    logAnalyticsWorkspaceResourceId: monitoring.outputs.logAnalyticsWorkspaceResourceId
    name: '${abbrs.appManagedEnvironments}${resourceToken}'
    location: location
    zoneRedundant: false
  }
}

module eshopliteProductsIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.2.1' = {
  name: 'eshopliteProductsidentity'
  params: {
    name: '${abbrs.managedIdentityUserAssignedIdentities}eshopliteProducts-${resourceToken}'
    location: location
  }
}

module eshopliteProductsFetchLatestImage './modules/fetch-container-image.bicep' = {
  name: 'eshopliteProducts-fetch-image'
  params: {
    exists: eshopliteProductsExists
    name: 'eshoplite-products'
  }
}

var eshopliteProductsAppSettingsArray = filter(array(eshopliteProductsDefinition.settings), i => i.name != '')
var eshopliteProductsSecrets = map(filter(eshopliteProductsAppSettingsArray, i => i.?secret != null), i => {
  name: i.name
  value: i.value
  secretRef: i.?secretRef ?? take(replace(replace(toLower(i.name), '_', '-'), '.', '-'), 32)
})
var eshopliteProductsEnv = map(filter(eshopliteProductsAppSettingsArray, i => i.?secret == null), i => {
  name: i.name
  value: i.value
})

module eshopliteProducts 'br/public:avm/res/app/container-app:0.8.0' = {
  name: 'eshopliteProducts'
  params: {
    name: 'eshoplite-products'
    ingressTargetPort: 8080
    scaleMinReplicas: 1
    scaleMaxReplicas: 10
    secrets: {
      secureList:  union([
      ],
      map(eshopliteProductsSecrets, secret => {
        name: secret.secretRef
        value: secret.value
      }))
    }
    containers: [
      {
        image: eshopliteProductsFetchLatestImage.outputs.?containers[?0].?image ?? 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
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
            value: eshopliteProductsIdentity.outputs.clientId
          }
          {
            name: 'PORT'
            value: '8080'
          }
        ],
        eshopliteProductsEnv,
        map(eshopliteProductsSecrets, secret => {
            name: secret.name
            secretRef: secret.secretRef
        }))
      }
    ]
    managedIdentities:{
      systemAssigned: false
      userAssignedResourceIds: [eshopliteProductsIdentity.outputs.resourceId]
    }
    registries:[
      {
        server: containerRegistry.outputs.loginServer
        identity: eshopliteProductsIdentity.outputs.resourceId
      }
    ]
    environmentResourceId: containerAppsEnvironment.outputs.resourceId
    location: location
    tags: union(tags, { 'azd-service-name': 'eshoplite-products' })
  }
}

module eshopliteStoreIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.2.1' = {
  name: 'eshopliteStoreidentity'
  params: {
    name: '${abbrs.managedIdentityUserAssignedIdentities}eshopliteStore-${resourceToken}'
    location: location
  }
}

module eshopliteStoreFetchLatestImage './modules/fetch-container-image.bicep' = {
  name: 'eshopliteStore-fetch-image'
  params: {
    exists: eshopliteStoreExists
    name: 'eshoplite-store'
  }
}

var eshopliteStoreAppSettingsArray = filter(array(eshopliteStoreDefinition.settings), i => i.name != '')
var eshopliteStoreSecrets = map(filter(eshopliteStoreAppSettingsArray, i => i.?secret != null), i => {
  name: i.name
  value: i.value
  secretRef: i.?secretRef ?? take(replace(replace(toLower(i.name), '_', '-'), '.', '-'), 32)
})
var eshopliteStoreEnv = map(filter(eshopliteStoreAppSettingsArray, i => i.?secret == null), i => {
  name: i.name
  value: i.value
})

module eshopliteStore 'br/public:avm/res/app/container-app:0.8.0' = {
  name: 'eshopliteStore'
  params: {
    name: 'eshoplite-store'
    ingressTargetPort: 8080
    scaleMinReplicas: 1
    scaleMaxReplicas: 10
    secrets: {
      secureList:  union([
      ],
      map(eshopliteStoreSecrets, secret => {
        name: secret.secretRef
        value: secret.value
      }))
    }
    containers: [
      {
        image: eshopliteStoreFetchLatestImage.outputs.?containers[?0].?image ?? 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
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
            value: eshopliteStoreIdentity.outputs.clientId
          }
          {
            name: 'PORT'
            value: '8080'
          }
          {
            name: 'ProductsApi'
            value: 'https://${eshopliteProducts.outputs.fqdn}'
          }
          {
            name: 'WeatherApi'
            value: 'https://${eshopliteWeather.outputs.fqdn}'
          }
        ],
        eshopliteStoreEnv,
        map(eshopliteStoreSecrets, secret => {
            name: secret.name
            secretRef: secret.secretRef
        }))
      }
    ]
    managedIdentities:{
      systemAssigned: false
      userAssignedResourceIds: [eshopliteStoreIdentity.outputs.resourceId]
    }
    registries:[
      {
        server: containerRegistry.outputs.loginServer
        identity: eshopliteStoreIdentity.outputs.resourceId
      }
    ]
    environmentResourceId: containerAppsEnvironment.outputs.resourceId
    location: location
    tags: union(tags, { 'azd-service-name': 'eshoplite-store' })
  }
}

module eshopliteWeatherIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.2.1' = {
  name: 'eshopliteWeatheridentity'
  params: {
    name: '${abbrs.managedIdentityUserAssignedIdentities}eshopliteWeather-${resourceToken}'
    location: location
  }
}

module eshopliteWeatherFetchLatestImage './modules/fetch-container-image.bicep' = {
  name: 'eshopliteWeather-fetch-image'
  params: {
    exists: eshopliteWeatherExists
    name: 'eshoplite-weather'
  }
}

var eshopliteWeatherAppSettingsArray = filter(array(eshopliteWeatherDefinition.settings), i => i.name != '')
var eshopliteWeatherSecrets = map(filter(eshopliteWeatherAppSettingsArray, i => i.?secret != null), i => {
  name: i.name
  value: i.value
  secretRef: i.?secretRef ?? take(replace(replace(toLower(i.name), '_', '-'), '.', '-'), 32)
})
var eshopliteWeatherEnv = map(filter(eshopliteWeatherAppSettingsArray, i => i.?secret == null), i => {
  name: i.name
  value: i.value
})

module eshopliteWeather 'br/public:avm/res/app/container-app:0.8.0' = {
  name: 'eshopliteWeather'
  params: {
    name: 'eshoplite-weather'
    ingressTargetPort: 8080
    scaleMinReplicas: 1
    scaleMaxReplicas: 10
    secrets: {
      secureList:  union([
      ],
      map(eshopliteWeatherSecrets, secret => {
        name: secret.secretRef
        value: secret.value
      }))
    }
    containers: [
      {
        image: eshopliteWeatherFetchLatestImage.outputs.?containers[?0].?image ?? 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
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
            value: eshopliteWeatherIdentity.outputs.clientId
          }
          {
            name: 'PORT'
            value: '8080'
          }
        ],
        eshopliteWeatherEnv,
        map(eshopliteWeatherSecrets, secret => {
            name: secret.name
            secretRef: secret.secretRef
        }))
      }
    ]
    managedIdentities:{
      systemAssigned: false
      userAssignedResourceIds: [eshopliteWeatherIdentity.outputs.resourceId]
    }
    registries:[
      {
        server: containerRegistry.outputs.loginServer
        identity: eshopliteWeatherIdentity.outputs.resourceId
      }
    ]
    environmentResourceId: containerAppsEnvironment.outputs.resourceId
    location: location
    tags: union(tags, { 'azd-service-name': 'eshoplite-weather' })
  }
}
// Create a keyvault to store secrets
module keyVault 'br/public:avm/res/key-vault/vault:0.6.1' = {
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
        objectId: eshopliteProductsIdentity.outputs.principalId
        permissions: {
          secrets: [ 'get', 'list' ]
        }
      }
      {
        objectId: eshopliteStoreIdentity.outputs.principalId
        permissions: {
          secrets: [ 'get', 'list' ]
        }
      }
      {
        objectId: eshopliteWeatherIdentity.outputs.principalId
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
output AZURE_RESOURCE_ESHOPLITE_PRODUCTS_ID string = eshopliteProducts.outputs.resourceId
output AZURE_RESOURCE_ESHOPLITE_STORE_ID string = eshopliteStore.outputs.resourceId
output AZURE_RESOURCE_ESHOPLITE_WEATHER_ID string = eshopliteWeather.outputs.resourceId
