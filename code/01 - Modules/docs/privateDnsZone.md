# Private DNS Zone
## Parameters
* *name*: **Required** - Name of the Private DNS Zone Service. For az private endpoints you might find info here: https://learn.microsoft.com/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration
* *tags*: **Optional** - Tags of the resource.
* *virtualNetworkLinks*: **Optional** - Array of custom objects describing vNet links of the DNS zone. Each object should contain vnetName, vnetId, registrationEnabled
* *aRecords*: **Optional** - Array of A records to be added to the DNS Zone

## Usage
var spokeVNetLinks = concat(
  [
    {
      vnetName: spokeVNetName
      vnetId: vnetSpoke.id
      registrationEnabled: false
    }
  ],
  [
    {
      vnetName: hubVNetName
      vnetId: hubVNetId
      registrationEnabled: false
    }
  ]
)

Use this as a parameter for virtualNetworkLinks

## Resource
[Bicep module](/code/01%20-%20Modules/modules/privateDnsZone.bicep)
