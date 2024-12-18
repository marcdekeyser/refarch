// ----- Parameters -----
@description('Keyvault suffix')
param suffix string

@description('Deployment location')
param location string

@description('Resource ID for the vNET the Private Endpoint will be deployed in')
param vNETResourceID string

@description('subnet resource ID for keyvault private endpoint')
param subnetResourceID string

@description('Zone name for private DNS')
param privateDnsZoneName string

// ----- Key Vault -----
// Create Keyvault
resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: 'kv-${suffix}'
  location: location
  properties: {
    createMode: 'default'
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    enableRbacAuthorization: true
    enablePurgeProtection: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    sku: {
      family: 'A'
      name: 'standard'
    }
    softDeleteRetentionInDays: 7
    tenantId: subscription().tenantId
  }
}

// Create Private Endpoint
resource keyVaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: 'pe-kv-${suffix}'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'pe-kv-${suffix}'
        properties: {
          groupIds: [
            'vault'
          ]
          privateLinkServiceId: keyVault.id
        }
      }
    ]
    subnet: {
      id: subnetResourceID
    }
  }
}

resource keyVaultPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
}

resource privateEndpointDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  name: '${keyVaultPrivateEndpoint.name}/vault-PrivateDnsZoneGroup'
  properties:{
    privateDnsZoneConfigs: [
      {
        name: privateDnsZoneName
        properties:{
          privateDnsZoneId: keyVaultPrivateDnsZone.id
        }
      }
    ]
  }
}

resource keyVaultPrivateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${keyVaultPrivateDnsZone.name}/${uniqueString(keyVault.id)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vNETResourceID
    }
  }
}
