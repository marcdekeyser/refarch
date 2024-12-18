/*
  Deploy bastion resources

*/
// ---- Variables & Parameters ----
@description('This is the base name for each Azure resource name')
param baseName string

@description('The resource group location')
param location string = resourceGroup().location

@description('vnet name')
param vnetname string

@description('Bastion subnet name')
param bastionSubnetName string

@description('Bastion public ip resource ID')
param bastionPIPid string

resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: vnetname
}

resource bastionHost 'Microsoft.Network/bastionHosts@2021-08-01' = {
  name: 'bas-${baseName}'
  location: location
    properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/${bastionSubnetName}'
          }
          publicIPAddress: {
            id: bastionPIPid
          }
        }
      }
    ]
  }
}

