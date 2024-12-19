# Keyvault module
## Parameters

* *keyVaultName*: **Required** - Name of the keyvault
* *location*: Required - location for the service
* *tags*: **Optional** - Tags for the resource
* *sku*: **Optional** - SKU for the keyvault
* *enabledForDeployment*: **Optional** - Property to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault
* *enabledForDiskEncryption*: **Optional** - Property to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys
* *enabledForTemplateDeployment*: **Optional**, Property to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault
* *enablePurgeProtection*: **Optional** - Property specifying whether protection against purge is enabled for this vault
* *enableRbacAuthorization*: **Optional** - Property that controls how data actions are authorized
* *enableSoftDelete*: **Optional** - Property to specify whether the soft delete functionality is enabled for this key vault -
* *publicNetworkAccess *: **Optional** - Property to specify whether the vault will accept traffic from public internet.

## Resources
[Bicep module](/code/01%20-%20Modules/modules/keyvault.bicep)