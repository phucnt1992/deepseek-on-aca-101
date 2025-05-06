// This module deploys an Azure Operational Insights workspace.

@description('Name of the workspace to be created')
@minLength(1)
@maxLength(63)
param name string

@description('Location of the workspace to be created')
@minLength(1)
param location string

@description('Name of the resource group to be created')
@minLength(1)
@maxLength(90)
param resourceGroupName string

@description('Tags to be applied to the resources')
param tags object = {}

module resourceGroup 'br/public:avm/res/resources/resource-group:0.4.1' = {
  name: 'resourceGroup'
  scope: resourceGroup
  params: {
    name: resourceGroupName
    location: location
    tags: tags
  }
}

module workspace 'br/public:avm/res/operational-insights/workspace:0.11.1' = {
  name: 'workspace'
  params: {
    // Required parameters
    name: name
    // Non-required parameters
    location: location
  }
}
