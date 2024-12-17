// ---- Parameters ----
@description('Name of the workload')
param appname string = 'app'

@description('Workload environment')
@allowed([
  'prod'
  'acc'
  'test'
  'dev'
])
param env string = 'prod'

@description('Location for the workload')
param location string = resourceGroup().location

// HUB vNET params
@description('HUB vNET CIDR')
param hubvnetAddressPrefix string = '10.3.0.0/16'

@description('HUB Services subnet CIDR')
param ServicesSubnetPrefix string = '10.3.0.0/24'

@description('HUB Bastion subnet CIDR')
param BastionSubnetPrefix string = '10.3.1.0/24'

@description('HUB Management subnet CIDR')
param ManagementSubnetPrefix string = '10.3.2.0/24'

@description('HUB Runner agents subnet CIDR')
param RunnersSubnetPrefix string = '10.3.3.0/24'

// Spoke vNET params
@description('spoke vNET CIDR')
param spokeVnetAddressPrefix string = '10.2.0.0/16'

@description('Spoke front-end subnet CIDR')
param spokeFrontendSubnetPrefix string = '10.2.0.0/24'

@description('Spoke business logic subnet CIDR')
param spokeMidtierSubnetPrefix string = '10.2.1.0/24'

@description('Spoke back-end subnet CIDR')
param spokeBackendSubnetPrefix string = '10.2.2.0/24'

@description('Spoke services subnet CIDR')
param spokeServicesSubnetPrefix string = '10.2.3.0/24'

// VM params
@description('Management VM username')
param managementVMUser string = 'azAdmin'

@description('Management VM password')
@secure()
param managementVMPassword string = 'Welcome2024!' //This is not good practice since it's supposed to be secure!

@description('Runner Agent VM username')
param runnerVMUser string = 'azAdmin'

@description('Runner Agent VM password')
@secure()
param runnerVMPassword string = 'Welcome2024!' //This is not good practice since it's supposed to be secure!

// variables
var suffix = uniqueString(subscription().subscriptionId, resourceGroup().id)

// ---- Deploying log analytics workspace ----
module workspaceModule 'modules/loganalytics.bicep' = {
  name: 'la-deployment'
  params: {
    // Required parameters
    logworkspaceName: 'la-hub'
    // Non-required parameters
    location: location
    sku: 'PerGB2018'
    retention: 30
  }
}

// ---- Deploying Hub network resources ----
module hubNetwork 'modules/networkHub.bicep' = {
  name: 'HubNetwork-deployment'
  params:{
      location: location
      vnetAddressPrefix: hubvnetAddressPrefix
      bastionSubnetPrefix: BastionSubnetPrefix
      managementSubnetPrefix: ManagementSubnetPrefix
      runneragentSubnetPrefix: RunnersSubnetPrefix
      servicesSubnetPrefix: ServicesSubnetPrefix
      logworkspaceid: workspaceModule.outputs.resourceId
  }
}

// ---- Deploying Bastion ----
// Have to deploy public IP address first
module bastionPublicIpAddress 'modules/publicip.bicep' = {
  name: 'PIP-Bastion-deployment'
  params:{
    publicIpAddressName: 'pip-bastion'
    location: location
    sku: 'Standard'
    publicIPAllocationMethod: 'Static'
    ddosProtectionMode: 'Enabled' 
  } 
}

// Deploying bastion service
module bastion 'modules/bastion.bicep' = {
  name: 'bastion-deployment'
  params: {
    baseName: 'Hub'
    location: location
    vnetname: 'vnet-hub'
    bastionSubnetName: 'AzureBastionSubnet'
    bastionPIPid: bastionPublicIpAddress.outputs.pipid
  }
  dependsOn:[
    hubNetwork
  ]
}

// ---- Deploying Azure Monitor Private Link Service ----
module AMPLS 'modules/ampls.bicep' = {
  name: 'AMPLS-Hub-Deployment'
  params:{
    location: location
    workspaceResourceID: workspaceModule.outputs.resourceId
    workspaceSubnetID: hubNetwork.outputs.servicesSubnetID
    vnetResourceID: hubNetwork.outputs.vnetResourceId
  }
}

// ---- Deploying management VM ----
module ManagementVM 'modules/vm.bicep' = {
  name: 'ManagementVM-Deployment'
  params:{
    location: location
    subnetId: hubNetwork.outputs.managementSubnetID
    // Windows computer name cannot be more than 15 characters long, be entirely numeric, or contain the following characters: ` ~ ! @ # $ % ^ & * ( ) = + _ [ ] { } \ | ; : . ' " , < > / ?.
    vmName: 'Mgmt01'
    vmAdminUserName: managementVMUser
    vmAdminPassword: managementVMPassword
    vmSize: 'Standard_B2ms'
  }
}

// ---- Deploying runner agent VM ----
module runnerAgentVM 'modules/vm.bicep' ={
  name: 'RunnerAgentVM-Deployment'
  params:{
    location: location
    subnetId: hubNetwork.outputs.runneragentSubnetID
    vmAdminPassword: runnerVMPassword
    vmAdminUserName: runnerVMUser
    // Windows computer name cannot be more than 15 characters long, be entirely numeric, or contain the following characters: ` ~ ! @ # $ % ^ & * ( ) = + _ [ ] { } \ | ; : . ' " , < > / ?.
    vmName: 'RA01'
    vmSize: 'Standard_B2ms'
  }
}

// ---- Deploying Spoke application network ----
module NetworkSpoke 'modules/networkSpoke.bicep' = {
  name: 'NetworkSpoke-${appname}-${env}-deployment'
  params:{
    baseName: '${location}-${appname}-${env}-${suffix}'
    location: location
    vnetAddressPrefix: spokeVnetAddressPrefix
    frontendSubnetPrefix: spokeFrontendSubnetPrefix
    midtierSubnetPrefix: spokeMidtierSubnetPrefix
    backendubnetPrefix: spokeBackendSubnetPrefix
    servicesSubnetPrefix: spokeServicesSubnetPrefix
    logworkspaceid: workspaceModule.outputs.resourceId
  }
}

// ---- Deploying peering between hub and spoke ----
module vNETPeering 'modules/peering.bicep' = {
name: 'vNETPeering-Deployment'
params:{
  sourceNetworkname:  'vnet-hub'
  destinationNetworkname: 'vnet-${location}-${appname}-${env}-${suffix}'
  }
  dependsOn:[
    NetworkSpoke
  ]
}

// ---- Deploying keyvault ----
module spokeKeyVault 'modules/keyvault.bicep' = {
  name: 'keyvault-${appname}-${env}-deployment'
  params:{
    suffix: suffix
    location: location
    vNETResourceID: NetworkSpoke.outputs.vnetResourceId
    subnetResourceID: NetworkSpoke.outputs.servicesSubnetID
    privateDnsZoneName: 'privatelink${environment().suffixes.keyvaultDns}'

  }
}


