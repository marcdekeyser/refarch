// ---- Parameters ----

@description('Name of the workload')
param appname string = 'app'
@description('Environment (Prod/Dev/Test)')
param environment string = 'prod'
@description('Location for the workload')
param location string = resourceGroup().location
@description('Log Analytics workspace')
param logworkspaceName string = 'la-${location}'

// CIDR for Network
param vnetAddressPrefix string = '10.0.0.0/16'
param appgwSubnetPrefix string = '10.0.1.0/24'
param frontendsSubnetPrefix string = '10.0.1.0/24'
param backendSubnetPrefix string = '10.0.2.0/24'

// ---- Variables ----
var suffix = uniqueString(subscription().subscriptionId, resourceGroup().id)
var baseName = '${location}-${appname}-${environment}-${suffix}'

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

// Deploy vnet with subnets and NSGs
module networkModule 'network.bicep' = {
  name: 'networkDeploy'
  params: {
    location: location
    baseName: baseName
    vnetAddressPrefix: vnetAddressPrefix
    appgwSubnetPrefix: appgwSubnetPrefix
    frontendsSubnetPrefix: frontendsSubnetPrefix
    backendSubnetPrefix: backendSubnetPrefix
    logworkspaceid: logWorkspace.id
  }
}
