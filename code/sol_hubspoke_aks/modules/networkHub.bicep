/*
  Deploy vnet with subnets and NSGs

*/

@description('The resource group location')
param location string = resourceGroup().location

@description('The CIDR range for the vnet')
param vnetAddressPrefix string

@description('The CIDR range for the bastion subnet')
param  bastionSubnetPrefix string

@description('The CIDR range for the management subnet')
param  managementSubnetPrefix string

@description('The CIDR range for the runneragents subnet')
param  runneragentSubnetPrefix string

@description('The CIDR range for the services subnet')
param  servicesSubnetPrefix string

@description('The ID of the logworkspace')
param logworkspaceid string

// variables
var vnetName = 'vnet-hub'
var bastionSubnetName = 'AzureBastionSubnet'
var managementSubnetName = 'snet-hub-management'
var runneragentSubnetName = 'snet-hub-runneragents'
var servicesSubnetName = 'snet-hub-services'

// ---- Network Security Groups ----
resource bastionSubnetNsg 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: 'nsg-hub-bastion'
  location: location
  properties: {
    securityRules: [
      {
        name: 'bastionInAllow'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'bastionControlInAllow'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRanges: [
            '443'
            '4443'
          ]
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowLoadBalancerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 140
          direction: 'Inbound'
        }
      }
      {
        name: 'bastionInDeny'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 900
          direction: 'Inbound'
        }
      }
      {
        name: 'bastionVnetOutAllow'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'bastionAzureOutAllow'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource nsgbastionSubnet_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: bastionSubnetNsg
  name: 'to-la'
  properties: {
    workspaceId: logworkspaceid
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}

resource managementSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-hub-management'
  location: location
  properties: {}
}

resource managementSubnetNsg_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: managementSubnetNsg
  name: 'to-la'
  properties: {
    workspaceId: logworkspaceid
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}

resource runneragentSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-hub-runneragent'
  location: location
  properties: {}
}

resource runneragentSubnetNsg_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: runneragentSubnetNsg
  name: 'to-la'
  properties: {
    workspaceId: logworkspaceid
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}

resource servicesSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-hub-services'
  location: location
  properties: {}
}

resource servicesSubnetNsg_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: servicesSubnetNsg
  name: 'to-la'
  properties: {
    workspaceId: logworkspaceid
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}

// ---- Virtual network ----
resource vnet 'Microsoft.Network/virtualNetworks@2022-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets:[
      {
        //bastion subnet
        name: bastionSubnetName
        properties: {
          addressPrefix: bastionSubnetPrefix
          networkSecurityGroup: {
            id: bastionSubnetNsg.id
          }
        }        
      }
      {
        //management subnet
        name: managementSubnetName
        properties: {
          addressPrefix: managementSubnetPrefix
          networkSecurityGroup: {
            id: managementSubnetNsg.id
          }
        }        
      }
      {
        //runner agent subnet
        name: runneragentSubnetName
        properties: {
          addressPrefix: runneragentSubnetPrefix
          networkSecurityGroup: {
            id: runneragentSubnetNsg.id
          }
        }        
      }
      {
        //services subnet
        name: servicesSubnetName
        properties: {
          addressPrefix: servicesSubnetPrefix
          networkSecurityGroup: {
            id: servicesSubnetNsg.id
          }
        }        
      }
    ]
  }
  resource bastionSubnet 'subnets' existing = {
    name: bastionSubnetName
  }
  resource managementSubnet 'subnets' existing = {
    name: managementSubnetName
  }
  resource runneragentSubnet 'subnets' existing = {
    name: runneragentSubnetName
  }
  resource servicesSubnet 'subnets' existing = {
    name: servicesSubnetName
  }
}

output vnetResourceId string = vnet.id
output bastionSubnetID string = vnet::bastionSubnet.id
output managementSubnetID string = vnet::managementSubnet.id
output runneragentSubnetID string = vnet::runneragentSubnet.id
output servicesSubnetID string = vnet::servicesSubnet.id

