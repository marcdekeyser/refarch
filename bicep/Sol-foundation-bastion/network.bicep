/*
  Deploy vnet with subnets and NSGs

*/

@description('This is the base name for each Azure resource name')
param baseName string

@description('The resource group location')
param location string = resourceGroup().location

@description('The CIDR range for the vnet')
param vnetAddressPrefix string

@description('The CIDR range for the FE subnet')
param  frontendsSubnetPrefix string

@description('The CIDR range for the BL Subnet')
param businesslogicSubnetPrefix string

@description('The CIDR range for the BE Subnet')
param backendSubnetPrefix string

@description('The CIDR range for the Bastion Subnet')
param AzureBastionSubnetPrefix string

@description('The CIDR range for the runner agents Subnet')
param agentsSubnetPrefix string

@description('The CIDR range for the Private endpoints Subnet')
param servicesSubnetPrefix string

@description('The CIDR range for the jumpbox Subnet')
param jumpSubnetPrefix string

@description('The ID of the logworkspace')
param logworkspaceid string

// variables
var vnetName = 'vnet-${baseName}'
var subnetFEName = 'snet-${baseName}-FrontEnd'
var subnetBLName = 'snet-${baseName}-MidTier'
var subnetBEName = 'snet-${baseName}-BackEnd'
var subnetBastionName = 'AzureBastionSubnet'
var subnetAgentsnName = 'snet-${baseName}-Agents'
var subnetJumpName = 'snet-${baseName}-Management'
var subnetServicesName = 'snet-${baseName}-Services'

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
        //Midtier subnet
        name: subnetBLName
        properties: {
          addressPrefix: businesslogicSubnetPrefix
          networkSecurityGroup: {
            id: midtierubnetNsg.id
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
        //Bastion subnet
        name: subnetBastionName
        properties: {
          addressPrefix: AzureBastionSubnetPrefix
          networkSecurityGroup: {
            id: bastionsubnetnsg.id
          }
        }
      }
      {
        //Agents subnet
        name: subnetAgentsnName
        properties: {
          addressPrefix: agentsSubnetPrefix
          networkSecurityGroup: {
            id: agentssubnetnsg.id
          }
        }
      }
      {
        //services subnet
        name: subnetServicesName
        properties: {
          addressPrefix: servicesSubnetPrefix
          networkSecurityGroup: {
            id: servicessubnetnsg.id
          }
        }
      }
      {
        //Management hosts subnet
        name: subnetJumpName
        properties: {
          addressPrefix: jumpSubnetPrefix
          networkSecurityGroup: {
            id: jumpsubnetnsg.id
          }
        }
      }
    ]
  }
  resource appfrontend 'subnets' existing = {
    name: subnetFEName
  }
  resource appmidtier 'subnets' existing = {
    name: subnetBLName
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

// front end subnet NSG
resource frontendSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-${baseName}-frontend'
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
          destinationAddressPrefix: frontendsSubnetPrefix
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
        name: 'Bastion.In.Allow'
        properties: {
          description: 'Allow inbound traffic from azure management subnet'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: jumpSubnetPrefix
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 130
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
        name: 'frontend.Out.Allow.backend'
        properties: {
          description: 'Allow outbound traffic from the front end subnet to the mid tier subnet.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: frontendsSubnetPrefix
          destinationAddressPrefix: businesslogicSubnetPrefix
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'AppPlan.Out.Allow.AzureMonitor'
        properties: {
          description: 'Allow outbound traffic from the front end subnet to Azure Monitor'
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

// mid tier subnet NSG
resource midtierubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-${baseName}-midtier'
  location: location
  properties: {
    securityRules: [
            {
        name: 'midtier.In.Allow.frontend'
        properties: {
          description: 'Allow ALL inbound traffic from the frontend subnet'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: frontendsSubnetPrefix
          destinationAddressPrefix: businesslogicSubnetPrefix
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'Bastion.In.Allow'
        properties: {
          description: 'Allow inbound traffic from azure management subnet'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: jumpSubnetPrefix
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 130
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
        name: 'frontend.Out.Allow.backend'
        properties: {
          description: 'Allow outbound traffic from the front end subnet to the mid tier subnet.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: frontendsSubnetPrefix
          destinationAddressPrefix: businesslogicSubnetPrefix
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource nsgbusinesslogicSubnet_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: midtierubnetNsg
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
        name: 'Bastion.In.Allow'
        properties: {
          description: 'Allow inbound traffic from azure management subnet'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: jumpSubnetPrefix
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      } 
      {
        name: 'PE.Out.Deny.All'
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

resource nsgbackendSubnet_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: backendSubnetNsg
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

//Bastion subnets NSG
resource bastionsubnetnsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-${baseName}-bastion'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowGatewayManagerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowLoadBalancerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
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
        name: 'AllowSshRdpOutBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowAzureCloudCommunicationOutBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowGetSessionInformationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          destinationPortRanges: [
            '80'
            '443'
          ]
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
      {
        name: 'DenyAllOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource nsgbastionSubnet_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: bastionsubnetnsg
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

//Agents subnets NSG
resource agentssubnetnsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-${baseName}-agents'
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource nsgagentsSubnet_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: agentssubnetnsg
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

//services subnets NSG
resource servicessubnetnsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-${baseName}-services'
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource nsgservicesSubnet_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: servicessubnetnsg
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

//management hosts subnets NSG
resource jumpsubnetnsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-${baseName}-management'
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource nsgjumpSubnet_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: jumpsubnetnsg
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


