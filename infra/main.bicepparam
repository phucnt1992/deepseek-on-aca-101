using 'main.bicep'

param environmentName = readEnvironmentVariable('AZURE_ENV_NAME', 'deepseek-on-aca')
param location = readEnvironmentVariable('AZURE_LOCATION', 'westus3')
