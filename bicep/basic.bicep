
param virtualNetworkName string
param vnetAddressPrefix string
param subnet1Name string
param subnet1Prefix string
param subnet2Name string
param subnet2Prefix string
param location string
param nsg1Name string
param nsg2Name string

//deploy virtual network
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [vnetAddressPrefix] 
    }
    subnets: [
      {
        name: subnet1Name
        properties: {
          addressPrefix: subnet1Prefix
          networkSecurityGroup: {
            id: resourceId('Microsoft.Network/networkSecurityGroups', nsg1Name)
          }
        }
      }
      {
        name: subnet2Name
        properties: {
          addressPrefix: subnet2Prefix
          networkSecurityGroup: {
            id: resourceId('Microsoft.Network/networkSecurityGroups', nsg2Name)
          }
        }
      }
    ]
  }
}

//deploy NSG resource 1
resource nsg1 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: nsg1Name
  location: location
  properties: {
    flushConnection: false
    securityRules: []
  }
} 

//deploy NSG resource 2
resource nsg2 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: nsg2Name
  location: location
  properties: {
    flushConnection: false
    securityRules: []
  }
}

