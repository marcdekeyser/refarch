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
param  frontendSubnetPrefix string

@description('The CIDR range for the management subnet')
param  midtierSubnetPrefix string

@description('The CIDR range for the runneragents subnet')
param  backendubnetPrefix string

@description('The CIDR range for the services subnet')
param  servicesSubnetPrefix string

@description('The ID of the logworkspace')
param logworkspaceid string

// variables
var vnetName = 'vnet-${baseName}'
var frontentSubnetName = 'snet-${baseName}-frontend'
var midtierSubnetName = 'snet-${baseName}-businesslogic'
var backendSubnetName = 'snet-${baseName}-backend'
var servicesSubnetName = 'snet-${baseName}-services'

// ---- Network Security Groups ----
resource frontendSubnetNsg 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: 'nsg-${baseName}-frontend'
  location: location
  properties: {}
}

resource nsgfrontendSubnet_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: frontendSubnetNsg
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

resource midtierSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-${baseName}-bussineslogic'
  location: location
  properties: {}
}

resource midtierSubnetNsg_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: midtierSubnetNsg
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
        //frontend subnet
        name: frontentSubnetName
        properties: {
          addressPrefix: frontendSubnetPrefix
          networkSecurityGroup: {
            id: frontendSubnetNsg.id
          }
        }        
      }
      {
        //midtier subnet
        name: midtierSubnetName
        properties: {
          addressPrefix: midtierSubnetPrefix
          networkSecurityGroup: {
            id: midtierSubnetNsg.id
          }
        }        
      }
      {
        //backend subnet
        name: backendSubnetName
        properties: {
          addressPrefix: backendubnetPrefix
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
  resource frontendSubnet 'subnets' existing = {
    name: frontentSubnetName
  }
  resource midtierSubnet 'subnets' existing = {
    name: midtierSubnetName
  }
  resource backendSubnet 'subnets' existing = {
    name: backendSubnetName
  }
  resource servicesSubnet 'subnets' existing = {
    name: servicesSubnetName
  }
}

output vnetResourceId string = vnet.id
output frontendSubnetID string = vnet::frontendSubnet.id
output midtierSubnetID string = vnet::midtierSubnet.id
output backendSubnetID string = vnet::backendSubnet.id
output servicesSubnetID string = vnet::servicesSubnet.id

