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

// Fixed Parameters
var suffix = uniqueString(subscription().subscriptionId, resourceGroup().id)
var baseName = '${location}-${appname}-prod-${suffix}'

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
    //logworkspaceid: logWorkspace.id
  }
}

module bastionModule 'bastion.bicep' = {
  name: 'bastion-deployment'
  params: {
    baseName: baseName
    location: location
    vnetname: 'vnet-${baseName}'
    bastionSubnetName: 'AzureBastionSubnet'
  }
  dependsOn:[
    networkModule
  ]
}
