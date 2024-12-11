/*** PARAMETERS ***/
@description('Name of the workload')
param appname string = 'app'
@description('Environment (Prod/Dev/Test)')
param environment string = 'prod'
@description('Location for the workload')
param location string = resourceGroup().location


/*** Variables ***/
var suffix = uniqueString(subscription().subscriptionId, resourceGroup().id)
var baseName = '${location}-${appname}-${environment}-${suffix}'
var vnetName = 'vnet-${baseName}'
var subnetFEName = 'snet-${baseName}-FrontEnd'
var subnetBLName = 'snet-${baseName}-BusinessLogic'
var subnetBEName = 'snet-${baseName}-BackEnd'

// CIDR for Network
var vnetAddressPrefix = '10.2.0.0/16'
var frontendsSubnetPrefix = '10.2.1.0/24'
var logicSubnetPrefix = '10.2.2.0/24'
var backendSubnetPrefix = '10.2.3.0/24'


// ---- Networking resources ----
// Virtual Network 1 and subnets
resource vnet 'Microsoft.Network/virtualNetworks@2022-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        //FrontEnd subnet
        name: subnetFEName
        properties: {
          addressPrefix: frontendsSubnetPrefix
        }
      }
      {
        //Business logic subnet
        name: subnetBLName
        properties: {
          addressPrefix: logicSubnetPrefix
        }
      }
      {
        //BackEnd subnet
        name: subnetBEName
        properties: {
          addressPrefix: backendSubnetPrefix
        }
      }
    ]
  }
}
