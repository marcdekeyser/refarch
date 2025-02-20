// ---- Parameters ----

@description('Name of the workload')
param appname string = 'app'

@description('Location for the workload')
param location string = resourceGroup().location
@description('Log Analytics workspace')
param logworkspaceName string = 'la-${location}'

var suffix = uniqueString(subscription().subscriptionId, resourceGroup().id)

var vnets = [
{
  // vnet 1

  vnetAddressPrefix: '10.2.0.0/16'
  frontendsSubnetPrefix: '10.2.0.0/24'
  logicSubnetPrefix: '10.2.1.0/24'
  backendSubnetPrefix: '10.2.2.0/24'
  baseName: '${location}-${appname}-prod-${suffix}'
}
{
  // vnet2
  vnetAddressPrefix: '10.3.0.0/16'
  frontendsSubnetPrefix: '10.3.0.0/24'
  logicSubnetPrefix: '10.3.1.0/24'
  backendSubnetPrefix: '10.3.2.0/24'
  baseName: '${location}-${appname}-dev-${suffix}'
}
]

// Availability Zones
//var availabilityZones = [ '1', '2', '3' ]

// ---- Log Analytics workspace ----
resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logworkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// Deploy vnet1 with subnets and NSGs
module networkModule 'vnet.bicep' = [for (item, i) in vnets:{
  name: '${item.baseName}-deployment'
  params: {
    location: location
    baseName: item.baseName
    vnetAddressPrefix: item.vnetAddressPrefix
    frontendsSubnetPrefix: item.frontendsSubnetPrefix
    businesslogicSubnetPrefix: item.logicSubnetPrefix
    backendSubnetPrefix: item.backendSubnetPrefix
    logworkspaceid: logWorkspace.id
  }
}]


