/*** PARAMETERS ***/
@description('Name of the workload')
param appname string = 'app'
@description('Environment (Prod/Dev/Test)')
param environment string = 'prod'
@description('Dataclassification of the workload')
param DataClassification string = 'General'
@description('What is the criticality of the workload? (Business critical, ...)')
param Criticatity string= 'Business Critical'
@description('Associated Business unit')
param BusinessUnit string= 'Corp'
@description('What is the commitment of the operations team?')
param OpsCommitment string = 'Workload Operations'
@description('Which team manages the workload?')
param OpsTeam string = 'Cloud Operations'
@description('Location for the workload')
param location string = resourceGroup().location
@description('Log Analytics workspace')
param laworkspaceName string = 'la-${location}'

param tagValues object = {
  workloadName: appname
  Environment: environment
  DataClassification: DataClassification
  Criticatity: Criticatity
  BusinessUnit: BusinessUnit
  OpsCommitment: OpsCommitment
  OpsTeam: OpsTeam
}

/*** Variables ***/
var suffix = uniqueString(subscription().subscriptionId, resourceGroup().id)
var baseName = '${location}-${appname}-${environment}-${suffix}'
var vnetName = 'vnet-${baseName}'
var subnetFEName = 'snet-${baseName}-FrontEnd'
var subnetBEName = 'snet-${baseName}-BackEnd'
var subnetAGName = 'snet-${baseName}-AppGW'
var subnetAgentsName = 'snet-${baseName}-Agents'

// CIDR for Network
var vnetAddressPrefix = '10.0.0.0/16'
var appGatewaySubnetPrefix = '10.0.1.0/24'
var frontendsSubnetPrefix = '10.0.0.0/24'
var backendSubnetPrefix = '10.0.2.0/24'
var agentsSubnetPrefix = '10.0.3.0/24'

// Availability Zones
var availabilityZones = [ '1', '2', '3' ]

/*** Log Analytics Workspace ***/
resource laworkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'la-${baseName}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}


// ---- Networking resources ----

// Virtual Networks and subnets
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
          networkSecurityGroup: {
            id: frontendSubnetNsg.id
          }
        }
      }
      {
        //BackEnd subnet
        name: subnetBEName
        properties: {
          addressPrefix: backendSubnetPrefix
          networkSecurityGroup: {
            id: backendSubnetNsg.id
          }
        }
      }
      {
        //app gateway subnet
        name: subnetAGName
        properties: {
          addressPrefix: appGatewaySubnetPrefix
          networkSecurityGroup: {
            id: appgatewaySubnetNsg.id
          }
        }
      }
      {
        // Build agents subnet
        name: subnetAgentsName
        properties: {
          addressPrefix: agentsSubnetPrefix
          networkSecurityGroup: {
            id: agentsSubnetNsg.id
          }
        }
      }
    ]
  }
  resource appGatewaySubnet 'subnets' existing = {
    name: subnetAGName
  }

  resource appfrontend 'subnets' existing = {
    name: subnetFEName
  }

  resource backendSubnet 'subnets' existing = {
    name: subnetBEName
  }

  resource agentsSubnet 'subnets' existing = {
    name: subnetAgentsName
  }  
  tags:tagValues
}

resource vnet_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'to-la'
  scope: vnet
  properties: {
    workspaceId: laworkspace.id
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// App gateway subnet NSG
resource appgatewaySubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-${baseName}-appgw'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AppGw.In.Allow.ControlPlane'
        properties: {
          description: 'Allow inbound Control Plane (https://docs.microsoft.com/azure/application-gateway/configuration-infrastructure#network-security-groups)'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '65200-65535'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AppGw.In.Allow443.Internet'
        properties: {
          description: 'Allow ALL inbound web traffic on port 443'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: appGatewaySubnetPrefix
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'AppGw.In.Allow.LoadBalancer'
        properties: {
          description: 'Allow inbound traffic from azure load balancer'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }      
      {
        name: 'DenyAllInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Inbound'
        }
      }  
      {
        name: 'AppGw.Out.Allow.frontend'
        properties: {
          description: 'Allow outbound traffic from the App Gateway subnet to the front end subnet.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: appGatewaySubnetPrefix
          destinationAddressPrefix: frontendsSubnetPrefix
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'AppPlan.Out.Allow.AzureMonitor'
        properties: {
          description: 'Allow outbound traffic from the App Gateway subnet to Azure Monitor'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: appGatewaySubnetPrefix
          destinationAddressPrefix: 'AzureMonitor'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource nsgappgwSubnet_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: appgatewaySubnetNsg
  name: 'to-la'
  properties: {
    workspaceId: laworkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}

//front end subnet nsg
resource frontendSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-${baseName}-frontend'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AppPlan.Out.Allow.PrivateEndpoints'
        properties: {
          description: 'Allow outbound traffic from the app service subnet to the back end subnet'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: frontendsSubnetPrefix
          destinationAddressPrefix: backendSubnetPrefix
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'AppPlan.Out.Allow.AzureMonitor'
        properties: {
          description: 'Allow outbound traffic from App service to the AzureMonitor ServiceTag.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: frontendsSubnetPrefix
          destinationAddressPrefix: 'AzureMonitor'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
    ]
  }
}

//Private endpoints subnets NSG
resource backendSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-${baseName}-backend'
  location: location
  properties: {
    securityRules: [
      {
        name: 'PE.Out.Deny.All'
        properties: {
          description: 'Deny outbound traffic from the private endpoints subnet'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: backendSubnetPrefix
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 100
          direction: 'Outbound'
        }
      }      
    ]
  }
}

//Build agents subnets NSG
resource agentsSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-${baseName}-buildagents'
  location: location
  properties: {
    securityRules: [
      {
        name: 'DenyAllOutBound'
        properties: {
          description: 'Deny outbound traffic from the build agents subnet. Note: adjust rules as needed after adding resources to the subnet'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: agentsSubnetPrefix
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Outbound'
        }
      }
    ]
  }
}
