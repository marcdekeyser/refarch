# Virtual Network peering
Creates a two way peer

## Parameters
* *sourceNetworkname*: **Required** - Name of the source network
* *destinationNetworkname*: **Required** - Name of the destination network
* *allowVirtualNetworkAccess*: **Optional** - Allow virtual network access
* *useRemoteGateways*: **Optional** - Allow the use of remote gateways
* *allowForwardedTraffic*: **Optional** - Allow forwarded traffic
* *allowGatewayTransit*: **Optional** - Allow gateway transit

## Resources
[Bicep module](/code/01%20-%20Modules/modules/peering.bicep)