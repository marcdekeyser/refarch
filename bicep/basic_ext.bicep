/*** PARAMETERS ***/
param appname string = 'app'
param environment string = 'prod'
param DataClassification string = 'General'
param Criticatity string= 'Business Critical'
param BusinessUnit string= 'Corp'
param OpsCommitment string = 'Workload Operations'
param OpsTeam string = 'Cloud Operations'
param location string = 'westeurope'

@description('Environment parameters')
param vnet string = 'vnet-${location}-${appname}-${environment}'
param snetappgw string = 'snet-${location}-${appname}-${environment}-appgw'
param snetfe string = 'snet-${location}-${appname}-${environment}-fe'
param snetbe string = 'snet-${location}-${appname}-${environment}-be'
param publicip string = 'pip-${location}-${appname}-${environment}'
param appgw string = 'agw-${location}-${appname}-${environment}'
param nsgbe string = 'nsg-${location}-${appname}-${environment}-be'
param nsgfe string = 'nsg-${location}-${appname}-${environment}-fe'
param nsgappgw string = 'nsg-${location}-${appname}-${environment}-appgw'
param laworkspacename string = 'la-${location}'

@description('Tags')
param tagValues object = {
  workloadName: appname
  Environment: environment
  DataClassification: DataClassification
  Criticatity: Criticatity
  BusinessUnit: BusinessUnit
  OpsCommitment: OpsCommitment
  OpsTeam: OpsTeam
}

/*** Log Analytics Workspace ***/
resource laworkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: laworkspacename
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
    forceCmkForQuery: false
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    features: {
      disableLocalAuth: false
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
  }
}

/*** Network Security Group ***/
@description('NSG for the app gw subnet. THis is just an example. Tailor to your security requirements!')
resource nsgappgw_resource 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: nsgappgw
  location: 'westeurope'
  properties: {
    securityRules: [
      {
        name: 'AllowAnyHTTPSInbound'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '10.2.0.0/24'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowAnyHTTPInbound'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '10.2.0.0/24'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Allow-Any-inbound-snetappgw-65200-65535'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          description: 'required for app gw'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '65200-65535'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource nsgAppGW_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: nsgappgw_resource
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

@description('NSG for the back-end subnet. THis is just an example. Tailor to your security requirements!')
resource nsgbe_resource 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: nsgbe
  location: 'westeurope'
  properties: {
    securityRules: [
      {
        name: 'Allow-snetFE-Inbound-SnetBE'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '10.2.1.0/24'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Deny-any-any'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource nsgbackEndSubnet_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: nsgbe_resource
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

@description('NSG for the front-end subnet. THis is just an example. Tailor to your security requirements!')
resource nsgfe_resource 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: nsgfe
  location: 'westeurope'
  properties: {
    securityRules: [
      {
        name: 'Allow-snetAPPGW-inbound-snetfe'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '10.2.0.0/24'
          destinationAddressPrefix: '10.2.1.0/24'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Deny-any-any'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource nsgFrontEndSubnet_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: nsgfe_resource
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

/*** Public IP Address for App GW ***/
resource publicip_resource 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: publicip
  location: 'westeurope'
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    ipAddress: '172.211.202.19'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

/*** Virtual Network ***/
@description('The virtual network.')
resource vnet_resource 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnet
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.2.0.0/16'
      ]
    }
    subnets: [
      {
        name: snetappgw
        properties: {
          addressPrefix: '10.2.1.0/24'
          networkSecurityGroup: { 
            id: nsgappgw_resource.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: snetfe
        properties: {
          addressPrefix: '10.2.1.0/24'
          networkSecurityGroup: { 
            id: nsgfe_resource.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: snetbe
        properties: {
          addressPrefix: '10.2.2.0/24'
          networkSecurityGroup: { 
            id: nsgbe_resource.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      
    ]
  }
  tags: tagValues
}

/*** Application Gateway ***/

resource appgw_resource 'Microsoft.Network/applicationGateways@2023-11-01' = {
  name: appgw
  location: 'westeurope'
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      family: 'Generation_1'
    }
    webApplicationFirewallConfiguration: true ? {
      enabled: true
      firewallMode: 'detection'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.2'
    } : null
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', snetappgw, nsgappgw)
          }
        }
      }
    ]
    sslCertificates: []
    trustedRootCertificates: []
    trustedClientCertificates: []
    sslProfiles: []
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIpIPv4'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicip_resource.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: '${appgw}-backend01'
        properties: {
          backendAddresses: []
        }
      }
    ]
    loadDistributionPolicies: []
    backendHttpSettingsCollection: [
      {
        name: 'bs-${appgw}-01'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
        }
      }
    ]
    backendSettingsCollection: []
    httpListeners: [
      {
        name: 'lrn-${appgw}-01'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appgw, 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appgw, 'port_80')
          }
          protocol: 'Http'
          hostNames: []
          requireServerNameIndication: false
          customErrorConfigurations: []
        }
      }
    ]
    listeners: []
    urlPathMaps: []
    requestRoutingRules: [
      {
        name: 'rr-${appgw}-01'
        properties: {
          ruleType: 'Basic'
          priority: 10
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appgw, 'httpListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appgw, 'BackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appgw, 'myHTTPSetting')
          }
        }
      }
    ]
    routingRules: []
    probes: []
    rewriteRuleSets: []
    redirectConfigurations: []
    privateLinkConfigurations: []
    enableHttp2: true
    autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: 2
    }
  }
  tags: tagValues
  dependsOn:[
    vnet_resource
  ]
}

