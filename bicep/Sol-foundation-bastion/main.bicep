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
param vnetAddressPrefix string = '10.2.0.0/16'
param frontendsSubnetPrefix string = '10.2.1.0/24'
param businesslogicSubnetPrefix string = '10.2.2.0/24'
param backendSubnetPrefix string = '10.2.3.0/24'
param AzureBastionSubnetPrefix string = '10.2.4.0/24'
param agentsSubnetPrefix string = '10.2.5.0/24'
param servicesSubnetPrefix string = '10.2.6.0/24'
param jumpSubnetPrefix string = '10.2.7.0/24'


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
    frontendsSubnetPrefix: frontendsSubnetPrefix
    businesslogicSubnetPrefix: businesslogicSubnetPrefix
    backendSubnetPrefix: backendSubnetPrefix
    AzureBastionSubnetPrefix: AzureBastionSubnetPrefix
    agentsSubnetPrefix: agentsSubnetPrefix
    servicesSubnetPrefix: servicesSubnetPrefix
    jumpSubnetPrefix: jumpSubnetPrefix
    logworkspaceid: logWorkspace.id
  }
}
