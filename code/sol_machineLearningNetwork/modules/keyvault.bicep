@description('Required. Name of the keyvault')
param keyVaultName string

@description('Required. location for the service')
param location string

@description('Optional. Tags for the resource')
param tags object = {}

@description('Optional. SKU for the keyvault')
@allowed([
  'standard' 
  'premium'
])
param sku string = 'standard'

@description('Optional. Property to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.')
param enabledForDeployment bool = true

@description('Optional. Property to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.')
param enabledForDiskEncryption bool

@description('Optional, Property to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault.')
param enabledForTemplateDeployment bool = true

@description('Optional. Property specifying whether protection against purge is enabled for this vault.')
param enablePurgeProtection bool = true

@description('Optional. Property that controls how data actions are authorized. ')
param enableRbacAuthorization bool = true

@description('Optional. Property to specify whether the soft delete functionality is enabled for this key vault.')
param enableSoftDelete bool = true

@allowed([
  'enabled'
  'disabled'
])
param publicNetworkAccess string

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' = {
  name: keyVaultName
  location: location  
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: sku
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    createMode: 'default'
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enablePurgeProtection: enablePurgeProtection
    enableRbacAuthorization: enableRbacAuthorization
    enableSoftDelete: enableSoftDelete
    publicNetworkAccess: publicNetworkAccess
  }
}
