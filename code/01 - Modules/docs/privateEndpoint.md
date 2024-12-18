# Private Endpoint
## Params
* *name*: **Required** - Name of your Private Endpoint. Must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens.
* *location*: **Required** -Location for all resources.
* *tags*: **Optional** - Tags of the resource.
* *snetID*: **Required** - The subnet resource ID where the nic of the PE will be attached to
* *privateLinkServiceId*: **Required** -The resource id of private link service. The resource ID of the Az Resource that we need to attach the pe to.
* *subresource*: **Required** The resource that the Private Endpoint will be attached to, as shown in https://learn.microsoft.com/azure/private-link/private-endpoint-overview#private-link-resource'
* *privateDnsZonesId*: **Required** Id of the relevant private DNS Zone, so that the PE can create an A record for the implicitly created nic

## Resource
[Bicep module](/code/01%20-%20Modules/modules/privateEndpoint.bicep)