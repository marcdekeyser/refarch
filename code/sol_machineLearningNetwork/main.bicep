@description('The name of the workload that is being deployed. Up to 10 characters long.')
@minLength(2)
@maxLength(10)
param workloadName string = 'AzML'

@description('Location for the resource')
param location string = 'westeurope'

@description('The name of the environment (e.g. "dev", "test", "prod", "uat", "dr", "qa"). Up to 8 characters long.')
@maxLength(8)
param env string = 'test'

@description('tags')
param tags object = {}

// ---- Variables ----
var vnetPrefix = ['10.2.0.0/16']
var bastionSubnetPrefix = '10.2.0.0/24'  
var managementSubnetPrefix = '10.2.1.0/24'
var mlComputeSubnetPrefix = '10.2.2.0/24'
var servicesSubnetPrefix = '10.2.3.0/24'
var namingRules = json(loadTextContent('resources/naming.jsonc'))
var VnetName = '${namingRules.resourceTypeAbbreviations.virtualNetwork}-${namingRules.regionAbbreviations[toLower(location)]}-${workloadName}-${env}'
var mgmtSubnetName = '${namingRules.resourceTypeAbbreviations.subnet}-${namingRules.regionAbbreviations[toLower(location)]}-${workloadName}-${env}-mgmt'
var mlComputeSubnetName = '${namingRules.resourceTypeAbbreviations.subnet}-${namingRules.regionAbbreviations[toLower(location)]}-${workloadName}-${env}-compute'
var servicesSubnetName = '${namingRules.resourceTypeAbbreviations.subnet}-${namingRules.regionAbbreviations[toLower(location)]}-${workloadName}-${env}-svc'
var bastionPipName = '${namingRules.resourceTypeAbbreviations.publicIpAddress}-${namingRules.regionAbbreviations[toLower(location)]}-${workloadName}-${env}'
var laName = '${namingRules.resourceTypeAbbreviations.logAnalyticsWorkspace}-${namingRules.regionAbbreviations[toLower(location)]}-${workloadName}-${env}'
var bastionNsgRules = loadJsonContent('resources/nsgBastionRules.jsonc', 'securityRules')

// Define private DNS zone name as array
param zones array = [
  'agentsvc.azure-automation.net'
  'blob.${environment().suffixes.storage}' // blob.core.windows.net
  'monitor.azure.com'
  'ods.opinsights.azure.com'
  'oms.opinsights.azure.com'
]

// ---- Deploying LA Workspace ----
module laWorkspace  'modules/logAnalyticsWorkspace.bicep' = {
  name: 'la-deployment'
  params:{
    name: laName
    location: location
    tags: tags
    publicNetworkAccessForIngestion: 'Disabled'
    publicNetworkAccessForQuery: 'Disabled'
  }
}

var Subnets = [
  {
    name: 'AzureBastionSubnet'
    properties: {
      addressPrefix: bastionSubnetPrefix   
      networkSecurityGroup: {
        id: nsgBastion.outputs.nsgId
      }
    }
  }
  {
    name: mgmtSubnetName
    properties: {
      addressPrefix: managementSubnetPrefix
      networkSecurityGroup: {
        id: nsgManagemtn.outputs.nsgId
      }
    }
  }
  {
    name: mlComputeSubnetName
    properties: {
      addressPrefix: mlComputeSubnetPrefix
    }
  }
  {
    name: servicesSubnetName
    properties: {
      addressPrefix: servicesSubnetPrefix
    }
  }
]

// ---- Deploying NSG ----
module nsgBastion 'modules/nsg.bicep' = {
  name: 'nsgBastion-Deployment'
  params:{
    name: 'nsgBastion'
    location: location
    tags: tags
    securityRules: bastionNsgRules
  }
}

// ---- Deploying NSG ----
module nsgManagemtn 'modules/nsg.bicep' = {
  name: 'nsgManagement-Deployment'
  params:{
    name: 'nsgManagement'
    location: location
    tags: tags
  }
}

// ---- Deploy virtual network ----
module vnet 'modules/vNET.bicep' = {
  name: 'vnet-deployment'
  params:{
    name: VnetName
    tags: tags
    location: location
    vnetAddressPrefixes: vnetPrefix
    subnets: Subnets
  }
}

// ---- Deploy Azure Bastion ----
// Need to create PIP first
module bastionPip 'modules/pip.bicep' = {
  name: 'bastionPip-Deployment'
  params:{
    name: bastionPipName
    location: location
    publicIPAllocationMethod: 'Static'
    skuName: 'Standard'
    skuTier: 'Global'
    ddosProtectionMode: 'Enabled'	
  }
}


