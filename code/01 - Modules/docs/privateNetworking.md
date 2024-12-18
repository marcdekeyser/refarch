# Private Networking
Combines private endpoint and private DNS zone in to one

## Paramets
* *virtualNetworkLinks*: **Optional** - Array of custom objects describing vNet links of the DNS zone. Each object should contain vnetName, vnetId, registrationEnabled
* *vnetHubResourceId*: **Optional** - if empty, private dns zone will be deployed in the current RG scope
* *subnetId*: Resource Id of the subnet, where the private endpoint and NIC will be attached to
* *azServiceId*: The Resource Id of Private Link Service. The Resource Id of the Az Resource that we need to attach the Private Endpoint to
* *azServicePrivateDnsZoneName*: Name of the Private DNS Zone Service. For az private endpoints you might find info here: https://learn.microsoft.com/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration
* *privateEndpointName*: Resource name of the Private Endpoint
* *privateEndpointSubResourceName*: The resource that the Private Endpoint will be attached to, as shown in https://learn.microsoft.com/azure/private-link/private-endpoint-overview#private-link-resource
* *location*: The region (location) in which the resource will be deployed. Default: resource group location.