/*
  Deploy vnet with subnets and NSGs

*/
@description('Base name for the application')
param baseName string 

@description('The resource group location')
param location string = resourceGroup().location

@description('The CIDR range for the vnet')
param vnetAddressPrefix string

@description('The CIDR range for the bastion subnet')
param  aksSubnetPrefix string

@description('The CIDR range for the management subnet')
param  backendSubnetPrefix string

@description('The CIDR range for the runneragents subnet')
param  loadbalancerSubnetPrefix string

@description('The CIDR range for the services subnet')
param  servicesSubnetPrefix string

@description('The ID of the logworkspace')
param logworkspaceid string

// variables
var vnetName = 'vnet-${baseName}'
var aksSubnetName = 'snet-${baseName}-aks'
var backendSubnetName = 'snet-${baseName}-backend'
var servicesSubnetName = 'snet-${baseName}-services'
var loadbalancerSubnetName = 'snet-${baseName}-loadbalancer'

// ---- Network Security Groups ----
resource aksSubnetNsg 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: 'nsg-${baseName}-aks'
  location: location
  properties: {}
}

resource nsgaksSubnet_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: aksSubnetNsg
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

resource backendSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-${baseName}-backend'
  location: location
  properties: {}
}

resource backendSubnetNsg_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: backendSubnetNsg
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

resource loadbalancerSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-${baseName}-loadbalancer'
  location: location
  properties: {}
}

resource loadbalancerSubnetNsg_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: loadbalancerSubnetNsg
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
  name: 'nsg-${baseName}-services'
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
        //fronteaksnd subnet
        name: aksSubnetName
        properties: {
          addressPrefix: aksSubnetPrefix
          networkSecurityGroup: {
            id: aksSubnetNsg.id
          }
        }        
      }
      {
        //loadbalancer subnet
        name: loadbalancerSubnetName
        properties: {
          addressPrefix: loadbalancerSubnetPrefix
          networkSecurityGroup: {
            id: loadbalancerSubnetNsg.id
          }
        }        
      }
      {
        //backend subnet
        name: backendSubnetName
        properties: {
          addressPrefix: backendSubnetPrefix
          networkSecurityGroup: {
            id: backendSubnetNsg.id
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
  resource aksSubnet 'subnets' existing = {
    name: aksSubnetName
  }
  resource backendSubnet 'subnets' existing = {
    name: backendSubnetName
  }
  resource loadbalancerSubnet 'subnets' existing = {
    name: loadbalancerSubnetName
  }
  resource servicesSubnet 'subnets' existing = {
    name: servicesSubnetName
  }
}

output vnetResourceId string = vnet.id
output aksSubnetID string = vnet::aksSubnet.id
output loadbalancerSubnetID string = vnet::backendSubnet.id
output backendSubnetID string = vnet::backendSubnet.id
output servicesSubnetID string = vnet::servicesSubnet.id

