@description('Required. Source network name')
param sourceNetworkname string

@description('Required. Remote network name')
param destinationNetworkname string

@description('Optional. Allow virtual network access')
param allowVirtualNetworkAccess bool = true

@description('Optional. Use remote gateways')
param useRemoteGateways bool = false

@description('Optional. Allow forwarded traffic')
param allowForwardedTraffic bool = true

@description('Optional. Allow gateway transit')
param allowGatewayTransit bool = false

resource sourceNetwork 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: sourceNetworkname
}

resource destinationNetwork 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: destinationNetworkname
}

resource sourceToDestinationPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'peer-to-${destinationNetworkname}'
  parent: sourceNetwork
  properties: {
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
    remoteVirtualNetwork: {
      id: destinationNetwork.id
    }
  }
}

resource destinationToSourcePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'peer-to-${sourceNetworkname}'
  parent: destinationNetwork
  properties: {
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
    remoteVirtualNetwork: {
      id: sourceNetwork.id
    }
  }
}
