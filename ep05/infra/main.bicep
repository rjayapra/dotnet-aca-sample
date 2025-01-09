targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

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

// Tags that should be applied to all resources.
// 
// Note that 'azd-service-name' tags should be applied separately to service host resources.
// Example usage:
//   tags: union(tags, { 'azd-service-name': <service name in azure.yaml> })
var tags = {
  'azd-env-name': environmentName
}

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

module resources 'resources.bicep' = {
  scope: rg
  name: 'resources'
  params: {
    location: location
    tags: tags
    principalId: principalId
    eshopliteProductsExists: eshopliteProductsExists
    eshopliteProductsDefinition: eshopliteProductsDefinition
    eshopliteStoreExists: eshopliteStoreExists
    eshopliteStoreDefinition: eshopliteStoreDefinition
    eshopliteWeatherExists: eshopliteWeatherExists
    eshopliteWeatherDefinition: eshopliteWeatherDefinition
  }
}
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = resources.outputs.AZURE_CONTAINER_REGISTRY_ENDPOINT
output AZURE_KEY_VAULT_ENDPOINT string = resources.outputs.AZURE_KEY_VAULT_ENDPOINT
output AZURE_KEY_VAULT_NAME string = resources.outputs.AZURE_KEY_VAULT_NAME
output AZURE_RESOURCE_ESHOPLITE_PRODUCTS_ID string = resources.outputs.AZURE_RESOURCE_ESHOPLITE_PRODUCTS_ID
output AZURE_RESOURCE_ESHOPLITE_STORE_ID string = resources.outputs.AZURE_RESOURCE_ESHOPLITE_STORE_ID
output AZURE_RESOURCE_ESHOPLITE_WEATHER_ID string = resources.outputs.AZURE_RESOURCE_ESHOPLITE_WEATHER_ID
