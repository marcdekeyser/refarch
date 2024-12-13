/*
  Deploy vnet with subnets and NSGs

*/
// ---- Variables & Parameters ----
@description('This is the base name for each Azure resource name')
param baseName string

@description('The resource group location')
param location string = resourceGroup().location

@description('vNET CIDR')
param vnetAddressPrefix string

@description('Front-end subnet CIDR')
param frontendsSubnetPrefix string

@description('Business logic subnet CIDR')
param logicSubnetPrefix string

@description('Back-end subnet CIDR')
param backendSubnetPrefix string

@description('Services subnet CIDR')
param ServicesSubnetPrefix string

@description('Bastion subnet CIDR')
param BastionSubnetPrefix string

@description('Management subnet CIDR')
param ManagementSubnetPrefix string

@description('Runner agents subnet CIDR')
param RunnersSubnetPrefix string

//@description('The ID of the logworkspace')
//param logworkspaceid string

// fixed variables
var vnetName = 'vnet-${baseName}'
var subnetFEName = 'snet-${baseName}-FrontEnd'
var subnetBLName = 'snet-${baseName}-MidTier'
var subnetBEName = 'snet-${baseName}-BackEnd'
var subnetSVSName = 'snet-${baseName}-Services'
var subnetBAName = 'AzureBastionSubnet' //stupid, I know, but bastion can only be created in a subnet with this name.
var subnetMGMTName = 'snet-${baseName}-Management'
var subnetRAName = 'snet-${baseName}-RunnerAgents'

// ---- Network Security Groups ----
resource bastionSubnetNsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
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

resource frontendSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-${baseName}-frontend'
  location: location
  properties: {}
}

resource logicSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-${baseName}-midtier'
  location: location
  properties: {}
}

resource backendSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-${baseName}-backend'
  location: location
  properties: {}
}

resource managementSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-${baseName}-management'
  location: location
  properties: {}
}

resource servicesSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-${baseName}-services'
  location: location
  properties: {}
}

resource runneragentsSubnetNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: 'nsg-${baseName}-runneragents'
  location: location
  properties: {}
}


// ---- Virtual network ----
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
          addressPrefix: logicSubnetPrefix
          networkSecurityGroup: {
            id: logicSubnetNsg.id
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
        //Services subnet
        name: subnetSVSName
        properties: {
          addressPrefix: ServicesSubnetPrefix
          networkSecurityGroup: {
            id: servicesSubnetNsg.id
          }
        }
      }
      {
        //Bastion subnet
        name: subnetBAName
        properties: {
          addressPrefix: BastionSubnetPrefix
          networkSecurityGroup: {
            id: bastionSubnetNsg.id
          }
        }
      }
      {
        //Management subnet
        name: subnetMGMTName
        properties: {
          addressPrefix: ManagementSubnetPrefix
          networkSecurityGroup: {
            id: managementSubnetNsg.id
          }
        }
      }
      {
        //Runner Agents subnet
        name: subnetRAName
        properties: {
          addressPrefix: RunnersSubnetPrefix
          networkSecurityGroup: {
            id: runneragentsSubnetNsg.id
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
  resource servicesSubnet 'subnets' existing = {
    name: subnetSVSName
  }
  resource BastionSubnet 'subnets' existing = {
    name: subnetBAName
  }
  resource ManagementSubnet 'subnets' existing = {
    name: subnetMGMTName
  }
  resource RunnersSubnet 'subnets' existing = {
    name: subnetRAName
  }
}
