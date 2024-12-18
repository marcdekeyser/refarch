
@description('Name of the workspace')
param logworkspaceName string

@description('Location of the workspace')
param location string

@description('SKU for the workspace')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
])
param sku string

@description('Retention time in days for the workspace. 730 Days is the max for non unlimited skus')
param retention int

// ---- Log Analytics workspace ----
resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logworkspaceName
  location: location
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retention
    publicNetworkAccessForIngestion: 'Disabled'
    publicNetworkAccessForQuery: 'Disabled'
  }
}

@description('The resource ID of the deployed log analytics workspace.')
output resourceId string = logWorkspace.id
