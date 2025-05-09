targetScope = 'resourceGroup'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

// Tags that should be applied to all resources.
//
// Note that 'azd-service-name' tags should be applied separately to service host resources.
// Example usage:
//   tags: union(tags, { 'azd-service-name': <service name in azure.yaml> })
var tags = {
  environment: environmentName
  event: 'DevCafe'
}

// Check if resource group already exists
module resources 'resources.bicep' = {
  name: 'deployResources'
  params: {
    location: location
    tags: tags
  }
}
