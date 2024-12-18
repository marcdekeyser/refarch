/*
  Deploy vnet with subnets and NSGs

*/
@description('Base name for the application')
param baseName string 

@description('The resource group location')
param location string = resourceGroup().location

@description('The CIDR range for the vnet')
param vnetAddressPrefix string

@description('The CIDR range for the ACA subnet')
param  spokeACASubnetPrefix string

@description('The CIDR range for the loadbalancer subnet')
param  spokeloadbalancerSubnetPrefix string

@description('The CIDR range for the backend subnet')
param  spokeBackendSubnetPrefix string

@description('The CIDR range for the services subnet')
param  spokeServicesSubnetPrefix string

@description('The ID of the logworkspace')
param logworkspaceid string

// variables
var vnetName = 'vnet-${baseName}'
var acaSubnetName = 'snet-${baseName}-aca'
var backendSubnetName = 'snet-${baseName}-backend'
var servicesSubnetName = 'snet-${baseName}-services'
var loadbalancerSubnetName = 'snet-${baseName}-loadbalancer'

// ---- Network Security Groups ----
resource acaSubnetNsg 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: 'nsg-${baseName}-aca'
  location: location
  properties: {}
}

resource nsgaksSubnet_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: acaSubnetNsg
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
        //aca subnet
        name: acaSubnetName
        properties: {
          addressPrefix: spokeACASubnetPrefix
          networkSecurityGroup: {
            id: acaSubnetNsg.id
          }
          delegations:[
            {
              name: 'acadelegation'
              properties: {
                serviceName: 'Microsoft.App/environments'
              }
            }
          ]
        }        
      }
      {
        //loadbalancer subnet
        name: loadbalancerSubnetName
        properties: {
          addressPrefix: spokeloadbalancerSubnetPrefix
          networkSecurityGroup: {
            id: loadbalancerSubnetNsg.id
          }
        }        
      }
      {
        //backend subnet
        name: backendSubnetName
        properties: {
          addressPrefix: spokeBackendSubnetPrefix
          networkSecurityGroup: {
            id: backendSubnetNsg.id
          }
        }        
      }
      {
        //services subnet
        name: servicesSubnetName
        properties: {
          addressPrefix: spokeServicesSubnetPrefix
          networkSecurityGroup: {
            id: servicesSubnetNsg.id
          }
        }        
      }
    ]
  }
  resource acaSubnet 'subnets' existing = {
    name: acaSubnetName
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
output acaSubnetID string = vnet::acaSubnet.id
output loadbalancerSubnetID string = vnet::backendSubnet.id
output backendSubnetID string = vnet::backendSubnet.id
output servicesSubnetID string = vnet::servicesSubnet.id

