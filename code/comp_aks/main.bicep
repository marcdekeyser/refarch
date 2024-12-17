// ---- Parameters ----
@description('Location for the workload')
param location string = resourceGroup().location

@description('AKS vNET CIDR')
param aksvnetAddressPrefix string = '10.3.0.0/16'

@description('AKS Cluster subnet CIDR')
param clusterSubnetPrefix string = '10.3.0.0/24'

@description('AKS Backend subnet CIDR')
param backendSubnetPrefix string = '10.3.1.0/24'

@description('AKS Services subnet CIDR')
param servicesSubnetPrefix string = '10.3.2.0/24'

@description('AKS Loadbalancer subnet CIDR')
param loadbalancerSubnetPrefix string = '10.3.3.0/24'

@description('Principle ID of the user to receive the AKS management roles')
param principleID string = '8de6be35-0187-4d5d-8cb6-05c601494bb6'

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

module aksNetwork 'modules/vNETAKS.bicep' = {
  name: 'vNET-AKS-Deployment'
  params:{
    baseName: '${location}-AKSCluster'
    location: location
    vnetAddressPrefix: aksvnetAddressPrefix
    aksSubnetPrefix: clusterSubnetPrefix
    backendSubnetPrefix: backendSubnetPrefix
    loadbalancerSubnetPrefix: loadbalancerSubnetPrefix
    servicesSubnetPrefix: servicesSubnetPrefix
    logworkspaceid: workspaceModule.outputs.resourceId    
  }
}

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

// ---- Deploying Azure Monitor Private Link Service ----
module AMPLS 'modules/ampls.bicep' = {
  name: 'AMPLS-Hub-Deployment'
  params:{
    location: location
    workspaceResourceID: workspaceModule.outputs.resourceId
    workspaceSubnetID: aksNetwork.outputs.servicesSubnetID
    vnetResourceID: aksNetwork.outputs.vnetResourceId
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

