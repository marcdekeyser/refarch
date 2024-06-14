/*
  Deploy vnet with subnets and NSGs

*/

@description('This is the base name for each Azure resource name')
param baseName string

@description('The resource group location')
param location string = resourceGroup().location

@description('The CIDR range for the vnet')
param vnetAddressPrefix string

@description('The CIDR range for the AG subnet')
param  appgwSubnetPrefix string

@description('The CIDR range for the FE subnet')
param  frontendsSubnetPrefix string

@description('The CIDR range for the BE Subnet')
param backendSubnetPrefix string

@description('The ID of the logworkspace')
param logworkspaceid string

// variables
var vnetName = 'vnet-${baseName}'
var subnetAGName = 'snet-${baseName}-appGW'
var subnetFEName = 'snet-${baseName}-FrontEnd'
var subnetBEName = 'snet-${baseName}-BackEnd'

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
        //App gateway subnet
        name: subnetAGName
        properties: {
          addressPrefix: appgwSubnetPrefix
          networkSecurityGroup: {
            id: appgwSubnetNsg.id
          }
        }
      }
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
    ]
  }
  resource appgateway 'subnets' existing = {
    name: subnetAGName
  }
  resource appfrontend 'subnets' existing = {
    name: subnetFEName
  }

  resource backendSubnet 'subnets' existing = {
    name: subnetBEName
  }
}

resource vnet_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'to-la'
  scope: vnet
  properties: {
    workspaceId: logworkspaceid
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// App gateway subnet NSG
resource appgwSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
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
          destinationAddressPrefix: appgwSubnetPrefix
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
        name: 'AppGw.Out.Allow.PrivateEndpoints'
        properties: {
          description: 'Allow outbound traffic from the App Gateway subnet to the frontend subnet.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: appgwSubnetPrefix
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
          sourceAddressPrefix: appgwSubnetPrefix
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
  scope: appgwSubnetNsg
  name: 'to-la'
  properties: {
    workspaceId: logworkspaceid
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
        name: 'frontend.Out.Allow.backend'
        properties: {
          description: 'Allow outbound traffic from the frontend subnet to the backend subnet'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: appgwSubnetPrefix
          destinationAddressPrefix: frontendsSubnetPrefix
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'AppPlan.Out.Allow.AzureMonitor'
        properties: {
          description: 'Allow outbound traffic from front end to the AzureMonitor ServiceTag.'
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

resource nsgfrontendSubnet_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: frontendSubnetNsg
  name: 'to-la'
  properties: {
    workspaceId: logworkspaceid
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}

//backend subnets NSG
resource backendSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-${baseName}-backend'
  location: location
  properties: {
    securityRules: [
      {
        name: 'backend.Out.Allow.AzureMonitor'
        properties: {
          description: 'Allow outbound traffic from front end to the AzureMonitor ServiceTag.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: backendSubnetPrefix
          destinationAddressPrefix: 'AzureMonitor'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
      {
        name: 'BE.Out.Deny.All'
        properties: {
          description: 'Deny outbound traffic from the backend subnet'
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
