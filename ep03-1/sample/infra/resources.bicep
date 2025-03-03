@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@description('The location used for all deployed resources')
param location string = resourceGroup().location

@description('Tags that will be applied to all resources')
param tags object = {}

param eshopLiteStoreExists bool
@secure()
param eshopLiteStoreDefinition object

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

// Storage account
module storageAccount 'br/public:avm/res/storage/storage-account:0.15.0' = {
  name: 'storageAccount'
  params: {
    name: '${abbrs.storageStorageAccounts}${resourceToken}'
    kind: 'StorageV2'
    location: location
    tags: tags
    skuName: 'Standard_LRS'
    blobServices: {
      containers: [
        {
          name: 'token-store'
          publicAccess: 'None'
        }
      ]
    }
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
    roleAssignments: [
      {
        principalId: eshopLiteStoreIdentity.outputs.principalId
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

module eshopLiteStoreIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.0' = {
  name: 'eshopLiteStoreIdentity'
  params: {
    name: '${abbrs.managedIdentityUserAssignedIdentities}eshoplitestore-${resourceToken}'
    location: location
  }
}

module eshopLiteStoreIdentityRoleAssignment './modules/role-assignment.bicep' = {
  name: 'eshopLiteStoreIdentityRoleAssignment'
  params: {
    managedIdentityName: eshopLiteStoreIdentity.outputs.name
    storageAccountName: storageAccount.outputs.name
    principalType: 'ServicePrincipal'
  }
}

module eshopLiteStoreFetchLatestImage './modules/fetch-container-image.bicep' = {
  name: 'eshoplite-store-fetch-image'
  params: {
    exists: eshopLiteStoreExists
    name: 'eshoplite-store'
  }
}

var eshopLiteStoreAppSettingsArray = filter(array(eshopLiteStoreDefinition.settings), i => i.name != '')
var eshopLiteStoreSecrets = map(filter(eshopLiteStoreAppSettingsArray, i => i.?secret != null), i => {
  name: i.name
  value: i.value
  secretRef: i.?secretRef ?? take(replace(replace(toLower(i.name), '_', '-'), '.', '-'), 32)
})
var eshopLiteStoreEnv = map(filter(eshopLiteStoreAppSettingsArray, i => i.?secret == null), i => {
  name: i.name
  value: i.value
})

module eshopLiteStore 'br/public:avm/res/app/container-app:0.11.0' = {
  name: 'eshopLiteStore'
  params: {
    name: 'eshoplite-store'
    ingressTargetPort: 8080
    scaleMinReplicas: 1
    scaleMaxReplicas: 10
    secrets: {
      secureList: union([
      ],
      map(eshopLiteStoreSecrets, secret => {
        name: secret.secretRef
        value: secret.value
      }))
    }
    containers: [
      {
        image: eshopLiteStoreFetchLatestImage.outputs.?containers[?0].?image ?? 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
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
            value: eshopLiteStoreIdentity.outputs.clientId
          }
          {
            name: 'PORT'
            value: '8080'
          }
        ],
        eshopLiteStoreEnv,
        map(eshopLiteStoreSecrets, secret => {
            name: secret.name
            secretRef: secret.secretRef
        }))
      }
    ]
    managedIdentities: {
      systemAssigned: false
      userAssignedResourceIds: [
        eshopLiteStoreIdentity.outputs.resourceId
      ]
    }
    registries: [
      {
        server: containerRegistry.outputs.loginServer
        identity: eshopLiteStoreIdentity.outputs.resourceId
      }
    ]
    environmentResourceId: containerAppsEnvironment.outputs.resourceId
    location: location
    tags: union(tags, { 'azd-service-name': 'eshoplite-store' })
  }
}

// EasyAuth
var issuer = '${environment().authentication.loginEndpoint}${tenant().tenantId}/v2.0'

module appRegistration './modules/app-registration.bicep' = {
  name: 'appRegistration'
  params: {
    appName: 'spn-${environmentName}'
    issuer: issuer
    containerAppIdentityId: eshopLiteStoreIdentity.outputs.principalId
    containerAppEndpoint: 'https://${eshopLiteStore.outputs.fqdn}'
  }
}

module eshopLiteStoreAuthConfig './modules/containerapps-authconfigs.bicep' = {
  name: 'eshopLiteStoreAuthConfig'
  params: {
    containerAppName: eshopLiteStore.outputs.name
    managedIdentityName: eshopLiteStoreIdentity.outputs.name
    storageAccountName: storageAccount.outputs.name
    clientId: appRegistration.outputs.appId
    openIdIssuer: issuer
    unauthenticatedClientAction: 'AllowAnonymous'
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
    accessPolicies: concat([
      {
        objectId: eshopLiteStoreIdentity.outputs.principalId
        permissions: {
          secrets: [ 'get', 'list' ]
        }
      }
    ], principalId != '' ? [
      {
        objectId: principalId
        permissions: {
          secrets: [ 'get', 'list' ]
        }
      }
    ] : [])
    secrets: [
    ]
  }
}

output AZURE_PRINCIPAL_ID string = appRegistration.outputs.appId

output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.outputs.loginServer
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.uri
output AZURE_KEY_VAULT_NAME string = keyVault.outputs.name

output AZURE_RESOURCE_CONTAINERAPP_ID string = eshopLiteStore.outputs.resourceId
output AZURE_RESOURCE_CONTAINERAPP_NAME string = eshopLiteStore.outputs.name
output AZURE_RESOURCE_CONTAINERAPP_URL string = 'https://${eshopLiteStore.outputs.fqdn}'
