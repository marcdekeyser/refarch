// ------------------
//    PARAMETERS
// ------------------

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

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

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
param spokeACASubnetPrefix string = '10.2.0.0/24'

@description('Spoke business logic subnet CIDR')
param spokeloadbalancerSubnetPrefix string = '10.2.1.0/24'

@description('Spoke back-end subnet CIDR')
param spokeBackendSubnetPrefix string = '10.2.2.0/24'

@description('Spoke services subnet CIDR')
param spokeServicesSubnetPrefix string = '10.2.3.0/24'

// Virtual machine params
@description('SKU Size for the virtual machines')
param vmSKU string = 'Standard_B2ms'

@description('The username to use for the virtual machine.')
param vmAdminUsername string

@description('The password to use for the virtual machine.')
@secure()
param vmAdminPassword string

var baseName = '${location}-${appname}-${env}'
var suffix = uniqueString(subscription().subscriptionId, resourceGroup().id)

// ------------------
// RESOURCES
// ------------------

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

module acaNetwork 'modules/networkSpoke.bicep' = {
  name: 'vNET-ACA-Deployment'
  params:{
    baseName: baseName
    location: location
    vnetAddressPrefix: spokeVnetAddressPrefix
    spokeACASubnetPrefix: spokeACASubnetPrefix
    spokeBackendSubnetPrefix: spokeBackendSubnetPrefix
    spokeloadbalancerSubnetPrefix: spokeloadbalancerSubnetPrefix
    spokeServicesSubnetPrefix: spokeServicesSubnetPrefix
    logworkspaceid: workspaceModule.outputs.resourceId    
  }
}

// ---- Deploying peering between hub and spoke ----
module vNETPeering 'modules/peering.bicep' = {
  name: 'vNETPeering-Deployment'
  params:{
    sourceNetworkname:  'vnet-hub'
    destinationNetworkname: 'vnet-${baseName}'
    }
    dependsOn:[
      acaNetwork
      hubNetwork
    ]
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
    vmAdminUserName: vmAdminUsername
    vmAdminPassword: vmAdminPassword
    vmSize: vmSKU
  }
}

// ---- Deploying runner agent VM ----
module runnerAgentVM 'modules/vm.bicep' ={
  name: 'RunnerAgentVM-Deployment'
  params:{
    location: location
    subnetId: hubNetwork.outputs.runneragentSubnetID
    vmAdminPassword: vmAdminUsername
    vmAdminUserName: vmAdminPassword
    // Windows computer name cannot be more than 15 characters long, be entirely numeric, or contain the following characters: ` ~ ! @ # $ % ^ & * ( ) = + _ [ ] { } \ | ; : . ' " , < > / ?.
    vmName: 'RA01'
    vmSize: vmSKU
  }
}

// ---- Deploying container registry ----
var privateDnsZoneNames = 'privatelink.azurecr.io'
var spokeVNetLinks = concat(
  [
    {
      vnetName: 'vnet-${baseName}'
      vnetId: acaNetwork.outputs.vnetResourceId
      registrationEnabled: false
    }
  ],
  [
    {
      vnetName: 'vnet-Hub'
      vnetId: hubNetwork.outputs.vnetResourceId
      registrationEnabled: false
    }
  ]
)

module containterRegistry 'modules/containerregistry.bicep' = {
  name: 'ACR-Deployment'
  params:{
    location: location
    name: 'acr${suffix}'
    acrSku: 'Premium'
    zoneRedundancy: 'Disabled'
    acrAdminUserEnabled: false
    publicNetworkAccess: 'Disabled'
    networkRuleBypassOptions: 'AzureServices'
    diagnosticWorkspaceId: workspaceModule.outputs.resourceId
    agentPoolSubnetId: acaNetwork.outputs.servicesSubnetID
  }
}

module containerRegistryNetwork 'modules/privatenetworking.bicep' = {
  name: 'ACR-Network-Deployment'
  params:{
    location: location
    azServicePrivateDnsZoneName: privateDnsZoneNames
    azServiceId: containterRegistry.outputs.resourceId
    privateEndpointName: 'pe-acr'
    privateEndpointSubResourceName: 'registry'
    virtualNetworkLinks: spokeVNetLinks
    subnetId: acaNetwork.outputs.servicesSubnetID
    vnetHubResourceId: hubNetwork.outputs.vnetResourceId
  }
}

// ---- Deploying keyvault ----
module KeyVault 'modules/keyvault.bicep' = {
  name: 'keyvault-deployment'
  params:{
    suffix: suffix
    location: location
    vNETResourceID: acaNetwork.outputs.vnetResourceId
    subnetResourceID: acaNetwork.outputs.servicesSubnetID
    privateDnsZoneName: 'privatelink${environment().suffixes.keyvaultDns}'
  }
}

// ---- Deploying Azure Container Apps ----
module containerAppsEnvironment 'modules/aca.bicep' = {
  name: 'ACA-deployment'
  params: {
    name: 'aca-${suffix}'
    location: location
    tags: tags
    diagnosticWorkspaceId: workspaceModule.outputs.resourceId
    subnetId: acaNetwork.outputs.acaSubnetID
    vnetEndpointInternal: true
    zoneRedundant: false
    infrastructureResourceGroupName: ''

  }
}

module containerAppsEnvironmentPrivateDnsZone 'modules/private-dns-zone.bicep' = {
  name: 'ACA-pDNS-Deployment}'
  params: {
    name: containerAppsEnvironment.outputs.containerAppsEnvironmentDefaultDomain
    virtualNetworkLinks: spokeVNetLinks
    tags: tags
    aRecords: [
      {
        name: '*'
        ipv4Address: containerAppsEnvironment.outputs.containerAppsEnvironmentLoadBalancerIP
      }
    ]
  }
}
