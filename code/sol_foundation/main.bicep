// ---- Parameters ----
@description('Name of the workload')
param appname string = 'app'

@description('Location for the workload')
param location string = resourceGroup().location

//@description('Log Analytics workspace')
//param logworkspaceName string = 'la-${location}'

@description('vNET CIDR')
param vnetAddressPrefix string = '10.2.0.0/16'

@description('Front-end subnet CIDR')
param frontendsSubnetPrefix string = '10.2.0.0/24'

@description('Business logic subnet CIDR')
param logicSubnetPrefix string = '10.2.1.0/24'

@description('Back-end subnet CIDR')
param backendSubnetPrefix string = '10.2.2.0/24'

@description('Services subnet CIDR')
param ServicesSubnetPrefix string = '10.2.3.0/24'

@description('Bastion subnet CIDR')
param BastionSubnetPrefix string = '10.2.4.0/24'

@description('Management subnet CIDR')
param ManagementSubnetPrefix string = '10.2.5.0/24'

@description('Runner agents subnet CIDR')
param RunnersSubnetPrefix string = '10.2.6.0/24'

// static Parameters
var suffix = uniqueString(subscription().subscriptionId, resourceGroup().id)
var baseName = '${location}-${appname}-prod-${suffix}'
// Define private DNS zone name as array
param zones array = [
  'agentsvc.azure-automation.net'
  'blob.${environment().suffixes.storage}' // blob.core.windows.net
  'monitor.azure.com'
  'ods.opinsights.azure.com'
  'oms.opinsights.azure.com'
]
// keyvault private dns zone
var privateDnsZoneName = 'privatelink${environment().suffixes.keyvaultDns}'


// Deploy log analytics workspace
module workspaceModule 'loganalytics.bicep' = {
  name: 'la-deployment'
  params: {
    // Required parameters
    logworkspaceName: 'la-${baseName}'
    // Non-required parameters
    location: location
    sku: 'PerGB2018'
    retention: 30
  }
}

// Deploy network resources
module networkModule 'network.bicep' = {
  name: 'vnet-deployment'
  params: {
    location: location
    baseName: baseName
    vnetAddressPrefix: vnetAddressPrefix
    frontendsSubnetPrefix: frontendsSubnetPrefix
    logicSubnetPrefix: logicSubnetPrefix
    backendSubnetPrefix: backendSubnetPrefix
    ServicesSubnetPrefix: ServicesSubnetPrefix
    BastionSubnetPrefix: BastionSubnetPrefix
    ManagementSubnetPrefix: ManagementSubnetPrefix
    RunnersSubnetPrefix: RunnersSubnetPrefix
    logworkspaceid: workspaceModule.outputs.resourceId
  }
}

// deploy bastion
module bastionModule 'bastion.bicep' = {
  name: 'bastion-deployment'
  params: {
    baseName: baseName
    location: location
    vnetname: networkModule.outputs.name
    bastionSubnetName: 'AzureBastionSubnet'
  }
}
// ---- Monitoring bits for Azure Monitor Private Link ----
// Azure Monitor Private Link Scope
resource Ampls 'microsoft.insights/privateLinkScopes@2021-07-01-preview' = {
  name: 'ampls-${baseName}'
  location: 'global'
  properties: {
    accessModeSettings: {
      // exclusions: [
      //   {
      //     ingestionAccessMode: 'string'
      //     privateEndpointConnectionName: 'string'
      //     queryAccessMode: 'string'
      //   }
      // ]
      ingestionAccessMode: 'PrivateOnly' // PrivateOnly, Open
      queryAccessMode: 'Open'
    }
  }
}

// Create Private Endpoint
resource PeAmpls 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: 'pe-ampls-${suffix}'
  location: location
  properties: {
    subnet: {
      id: networkModule.outputs.servicessubnetid
    }
    privateLinkServiceConnections: [
      {
        name: 'pe-ampls-connection'
        properties: {
          privateLinkServiceId: Ampls.id
          groupIds: [
            'azuremonitor'
          ]
        }
      }
    ]
    customNetworkInterfaceName: 'pe-ampls-${suffix}-nic'
  }
  dependsOn: privateDnsZoneForAmpls
}

// Connect Log Analytics Workspace to AMPLS
resource AmplsScopedLaw 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  name: 'amplsScopedLaw'
  parent: Ampls
  properties: {
    linkedResourceId: workspaceModule.outputs.resourceId
  }
}

// Create Private DNS Zone
// Define zone name as array
// https://blog.aimless.jp/archives/2022/07/use-integration-between-private-endpoint-and-private-dns-zone-in-bicep/#:~:text=Private%20Endpoint%20%E3%81%A8%20Private%20DNS%20Zone%20%E3%81%AE%E8%87%AA%E5%8B%95%E9%80%A3%E6%90%BA%E3%82%92%20Bicep,%E3%81%AE%E3%83%97%E3%83%A9%E3%82%A4%E3%83%99%E3%83%BC%E3%83%88%20IP%20%E3%82%A2%E3%83%89%E3%83%AC%E3%82%B9%E3%81%AB%E5%90%8D%E5%89%8D%E8%A7%A3%E6%B1%BA%E3%81%99%E3%82%8B%E5%BF%85%E8%A6%81%E3%81%8C%E3%81%82%E3%82%8A%E3%81%BE%E3%81%99%E3%80%82%20%E3%81%93%E3%81%AE%E5%90%8D%E5%89%8D%E8%A7%A3%E6%B1%BA%E3%82%92%E5%AE%9F%E7%8F%BE%E3%81%99%E3%82%8B%E3%81%9F%E3%82%81%E3%81%AE%E4%B8%80%E3%81%A4%E3%81%AE%E3%82%AA%E3%83%97%E3%82%B7%E3%83%A7%E3%83%B3%E3%81%8C%20Private%20DNS%20Zone%20%E3%81%A7%E3%81%99%E3%80%82
resource privateDnsZoneForAmpls 'Microsoft.Network/privateDnsZones@2020-06-01' = [for zone in zones: {
  name: 'privatelink.${zone}'
  location: 'global'
  properties: {
  }
}]

// Connect Private DNS Zone to VNet
resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (zone,i) in zones: { 
  parent: privateDnsZoneForAmpls[i]
  name: '${zone}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: networkModule.outputs.resourceId
    }
  }
}]

// Create Private DNS Zone Group for "pe-ampls" to register A records automatically
resource peDnsGroupForAmpls 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  parent: PeAmpls
  name: 'pvtEndpointDnsGroupForAmpls'
  properties: {
    privateDnsZoneConfigs: [
      for (zone,i) in zones: {
        name: privateDnsZoneForAmpls[i].name
        properties: {
          privateDnsZoneId: privateDnsZoneForAmpls[i].id
        }
      }
    ]
  }
}


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
      id: networkModule.outputs.servicessubnetid
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
      id: networkModule.outputs.resourceId
    }
  }
}
