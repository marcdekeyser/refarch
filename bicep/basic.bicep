/*** Variables ***/
var suffix = uniqueString(subscription().subscriptionId, resourceGroup().id)
param appname string = 'app'
param environment string = 'prod'
param DataClassification string = 'General'
param Criticatity string= 'Business Critical'
param BusinessUnit string= 'Corp'
param OpsCommitment string = 'Workload Operations'
param OpsTeam string = 'Cloud Operations'
param location string = 'westeurope'

param tagValues object = {
  workloadName: appname
  Environment: environment
  DataClassification: DataClassification
  Criticatity: Criticatity
  BusinessUnit: BusinessUnit
  OpsCommitment: OpsCommitment
  OpsTeam: OpsTeam
}

/*** Log Analytics Workspace ***/
resource laworkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'la-${location}-${suffix}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
    forceCmkForQuery: false
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    features: {
      disableLocalAuth: false
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
  }
}

/*** Network Security Groups ***/
@description('NSG for the front-end subnet. THis is just an example. Tailor to your security requirements!')
resource nsgFrontEndSubnet 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'nsg-${location}-${appname}-${environment}-fe-${suffix}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowAll443InFromAnywhere'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Inbound'
        }
      }
      //No Outbound restrictions
    ]
  }
}

resource nsgFrontEndSubnet_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: nsgFrontEndSubnet
  name: 'to-la'
  properties: {
    workspaceId: laworkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}

@description('NSG for the back-end subnet. THis is just an example. Tailor to your security requirements!')
resource nsgbackEndSubnet 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'nsg-${location}-${appname}-${environment}-be-${suffix}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowAll443InFromAnywhere'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '10.0.1.0/24'
          destinationPortRange: '443'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Inbound'
        }
      }
      //No Outbound restrictions
    ]
  }
}

resource nsgbackEndSubnet_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: nsgbackEndSubnet
  name: 'to-la'
  properties: {
    workspaceId: laworkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}

/*** Virtual Network ***/
@description('The virtual network.')
resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: 'vnet-${location}-${appname}-${environment}-${suffix}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-${location}-${appname}-${environment}-fe-${suffix}'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: { 
            id: nsgFrontEndSubnet.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'snet-${location}-${appname}-${environment}-be-${suffix}'
        properties: {
          addressPrefix: '10.0.2.0/24'
          networkSecurityGroup: { 
            id: nsgbackEndSubnet.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      
    ]
  }
  tags: tagValues
}

resource vnet_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'to-la'
  scope: vnet
  properties: {
    workspaceId: laworkspace.id
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

