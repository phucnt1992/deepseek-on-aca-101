@description('The location used for all deployed resources')
param location string = resourceGroup().location

@description('Tags that will be applied to all resources')
param tags object = {}

// Define variables
@description('Abbreviations for resource names')
var abbrs = loadJsonContent('./abbreviations.json')

@description('A unique token for resource naming')
var resourceToken = uniqueString(subscription().id, resourceGroup().id, location)

@description('The name of the workload profile to use for the container app')
var workloadProfileName = 'GPU'

@description('The name of the volume for Ollama')
var ollamaVolumeName = 'ollama'

@description('The name of the volume for Open WebUI')
var openWebUIVolumeName = 'open-webui'

// Monitor application with Azure Monitor
resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
  location: location
  tags: tags
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsight 'Microsoft.Insights/components@2020-02-02' = {
  name: '${abbrs.insightsComponents}${resourceToken}'
  location: location
  kind: 'web'
  tags: tags

  properties: {
    WorkspaceResourceId: logWorkspace.id
    Application_Type: 'web'
    RetentionInDays: 30
    SamplingPercentage: 100
    IngestionMode: 'LogAnalytics'
  }
}

// Storage account for container apps

resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: '${abbrs.storageStorageAccounts}${resourceToken}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  tags: tags

  properties: {
    largeFileSharesState: 'Enabled'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
  }

  resource fileServices 'fileServices' = {
    name: 'default'
    properties: {
      shareDeleteRetentionPolicy: {
        days: 7
        enabled: true
      }
    }

    resource ollama 'shares' = {
      name: ollamaVolumeName
      properties: {
        accessTier: 'TransactionOptimized'
        shareQuota: 5120
        enabledProtocols: 'SMB'
      }
    }

    resource openWebUI 'shares' = {
      name: openWebUIVolumeName
      properties: {
        accessTier: 'TransactionOptimized'
        shareQuota: 5120
        enabledProtocols: 'SMB'
      }
    }
  }
}

// Container apps environment
resource appEnv 'Microsoft.App/managedEnvironments@2025-01-01' = {
  // Primary settings
  name: '${abbrs.appManagedEnvironments}${resourceToken}'
  location: location

  // Settings
  properties: {
    zoneRedundant: false
    infrastructureResourceGroup: resourceGroup().name

    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logWorkspace.properties.customerId
        sharedKey: logWorkspace.listKeys().primarySharedKey
      }
    }

    // Ref: https://learn.microsoft.com/en-us/azure/container-apps/workload-profiles-overview
    workloadProfiles: [
      {
        name: 'default'
        workloadProfileType: 'Consumption'
      }
      {
        name: workloadProfileName
        workloadProfileType: 'Consumption-GPU-NC8as-T4'
      }
    ]
  }

  resource ollama 'storages' = {
    name: ollamaVolumeName
    properties: {
      azureFile: {
        accessMode: 'ReadWrite'
        accountKey: storageAccount.listKeys().keys[0].value
        accountName: storageAccount.name
        shareName: ollamaVolumeName
      }
    }
  }

  resource openWebUI 'storages' = {
    name: openWebUIVolumeName
    properties: {
      azureFile: {
        accessMode: 'ReadWrite'
        accountKey: storageAccount.listKeys().keys[0].value
        accountName: storageAccount.name
        shareName: openWebUIVolumeName
      }
    }
  }
}

resource app 'Microsoft.App/containerApps@2025-01-01' = {
  name: '${abbrs.appContainerApps}${resourceToken}'
  location: location
  tags: tags

  properties: {
    environmentId: appEnv.id
    workloadProfileName: workloadProfileName
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 8080
        transport: 'auto'
      }
    }
    template: {
      scale: {
        minReplicas: 0
        maxReplicas: 1
      }
      containers: [
        {
          image: 'ghcr.io/open-webui/open-webui:ollama'
          name: 'webui'
          resources: {
            cpu: json('8')
            memory: '56Gi'
          }
          env: [
            {
              name: 'WEBUI_AUTH'
              value: 'False'
            }
            {
              name: 'WEBUI_NAME'
              value: '☕️ DEV Cafe'
            }
          ]
          volumeMounts: [
            {
              volumeName: ollamaVolumeName
              mountPath: '/root/.ollama'
            }
            {
              volumeName: openWebUIVolumeName
              mountPath: '/app/backend/data'
            }
          ]
        }
      ]
      volumes: [
        {
          name: ollamaVolumeName
          storageType: 'AzureFile'
          storageName: ollamaVolumeName
          mountOptions: 'dir_mode=0775,file_mode=0775,nobrl'
        }
        {
          name: openWebUIVolumeName
          storageType: 'AzureFile'
          storageName: openWebUIVolumeName
          mountOptions: 'dir_mode=0775,file_mode=0775,nobrl'
        }
      ]
    }
  }
}
