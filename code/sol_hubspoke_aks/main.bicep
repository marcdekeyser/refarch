// ---- Parameters ----

@description('Location for the workload')
param location string = resourceGroup().location

//@description('Log Analytics workspace')
//param logworkspaceName string = 'la-${location}'

// HUB VNET Params
@description('HUB vNET CIDR')
param hubvnetAddressPrefix string = '10.2.0.0/16'

@description('HUB Services subnet CIDR')
param ServicesSubnetPrefix string = '10.2.0.0/24'

@description('HUB Bastion subnet CIDR')
param BastionSubnetPrefix string = '10.2.1.0/24'

@description('HUB Management subnet CIDR')
param ManagementSubnetPrefix string = '10.2.2.0/24'

@description('HUB Runner agents subnet CIDR')
param RunnersSubnetPrefix string = '10.2.3.0/24'

// AKS VNET PARAMS
@description('AKS vNET CIDR')
param aksvnetAddressPrefix string = '10.3.0.0/16'

@description('AKS Cluster subnet CIDR')
param clusterSubnetPrefix string = '10.3.0.0/24'

@description('AKS Backend subnet CIDR')
param backendSubnetPrefix string = '10.3.1.0/24'

@description('AKS Services subnet CIDR')
param aksservicesSubnetPrefix string = '10.3.2.0/24'

@description('AKS Loadbalancer subnet CIDR')
param loadbalancerSubnetPrefix string = '10.3.3.0/24'

@description('Principle ID of the user to receive the AKS management roles')
param principleID string = '8de6be35-0187-4d5d-8cb6-05c601494bb6'


// VM PARAMS
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

module aksNetwork 'modules/vNETAKS.bicep' = {
  name: 'vNET-AKS-Deployment'
  params:{
    baseName: '${location}-AKSCluster'
    location: location
    vnetAddressPrefix: aksvnetAddressPrefix
    aksSubnetPrefix: clusterSubnetPrefix
    backendSubnetPrefix: backendSubnetPrefix
    loadbalancerSubnetPrefix: loadbalancerSubnetPrefix
    servicesSubnetPrefix: aksservicesSubnetPrefix
    logworkspaceid: workspaceModule.outputs.resourceId    
  }
}

// ---- Deploying peering between hub and spoke ----
module vNETPeering 'modules/peering.bicep' = {
  name: 'vNETPeering-Deployment'
  params:{
    sourceNetworkname:  'vnet-hub'
    destinationNetworkname: 'vnet-${location}-AKSCluster'
    }
    dependsOn:[
      aksNetwork
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

// ---- Deploying AKS Cluster
module aksCluster 'modules/aks.bicep' = {
  name: 'Cluster-AKS-Deployment'
  params:{
    clustername: 'aks-managed-cluster-2812455'
    location: location
    monitoringWorkspaceResourceId: workspaceModule.outputs.resourceId 
    principalId: principleID //change this to your users principal ID
    systemPoolSize: 'CostOptimised'
    agentPoolSize: 'CostOptimised'
    disableLocalAccounts: true
    publicNetworkAccess: 'Disabled'
    enableKeyvaultSecretsProvider: true
    subnetresourceID: aksNetwork.outputs.aksSubnetID  
      
  }
}

// ---- Deploying keyvault ----
module KeyVault 'modules/keyvault.bicep' = {
  name: 'keyvault-deployment'
  params:{
    suffix: suffix
    location: location
    vNETResourceID: aksNetwork.outputs.vnetResourceId
    subnetResourceID: aksNetwork.outputs.servicesSubnetID
    privateDnsZoneName: 'privatelink${environment().suffixes.keyvaultDns}'
  }
}

module acr 'modules/containerregistry.bicep' = {
  name: 'ACR-Deployment'
  params:{
    acrName: 'Acraks57515' //ALPHANUMERIC ONLY
    acrSku: 'Premium'
    location: location
    subnetresourceID: aksNetwork.outputs.servicesSubnetID
    workspaceResourceId: workspaceModule.outputs.resourceId
  }
}
