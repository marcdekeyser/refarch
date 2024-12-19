# Azure open AI
## Parameters
* *name*: **Required** - Name of the OpenAI Account. Must be globally unique. Only alphanumeric characters and hyphens are allowed. The value must be 2-64 characters long and cannot start or end with a hyphen
* *kind*: **Optional** - Default is OpenAI. Kind of the Cognitive Services. Find available Kind-SKUs compination by running `az cognitiveservices account list-skus --kind OpenAI --location EASTUS2`  Check here: https://learn.microsoft.com/azure/ai-services/create-account-bicep?tabs=CLI.
* *sku*: **Optional** - Default is S0 for OpenAI. SKU of the Cognitive Services resource. Use \'Get-AzCognitiveServicesAccountSku\' to determine a valid combinations of \'kind\' and \'SKU\' for your Azure region.
* *location*: **Optional** - Location for all Resources.
* *diagnosticSettings*: **Optional** - The diagnostic settings of the service.
* *publicNetworkAccess*: **Optional** - Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set and networkAcls are not set.
* *customSubDomainName*: **Conditional** - Subdomain name used for token-based authentication. Required if \'networkAcls\' or \'privateEndpoints\' are set.
* *networkAcls*: **Optional** - A collection of rules governing the accessibility from specific network locations.
* *hasPrivateLinks*: Whether the resource has private links or not
* *systemAssignedIdentity*: **Optional** - default is true. Enables system assigned managed identity on the resource.
* *userAssignedIdentities*: **Conditional** - The ID(s) to assign to the resource. Required if a user assigned identity is used for encryption.
* *lock*: **Optional** - The lock settings of the service.
* *roleAssignments*:**Optional** - Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.
* *tags*: **Optional** - Tags of the resource.
* *allowedFqdnList*: **Optional** - List of allowed FQDN.
* *apiProperties*: **Optional** - The API properties for special APIs.
* *disableLocalAuth*: **Optional** - Allow only Azure AD authentication. Should be enabled for security reasons.')
* *cMKKeyVaultResourceId*: **Conditional** - The resource ID of a key vault to reference a customer managed key for encryption from. Required if \'cMKKeyName\' is not empty.
* *cMKKeyName*: **Optional** - The name of the customer managed key to use for encryption. Cannot be deployed together with the parameter \'systemAssignedIdentity\' enabled.
* *cMKUserAssignedIdentityResourceId*: **Conditional** - User assigned identity to use when fetching the customer managed key. Required if \'cMKKeyName\' is not empty.
* *cMKKeyVersion*: **Optional** - The version of the customer managed key to reference for encryption. If not provided, latest is used.
* *dynamicThrottlingEnabled*: **Optional** - The flag to enable dynamic throttling.
* *migrationToken*: **Optional** - Resource migration token.
* *restore*: **Optional** - Restore a soft-deleted cognitive service at deployment time. Will fail if no such soft-deleted resource exists.
* *restrictOutboundNetworkAccess*: **Optional** - Restrict outbound network access.
* *userOwnedStorage*: **Optional** - The storage accounts for this resource.
* *enableDefaultTelemetry*: **Optional** - Enable telemetry via a Globally Unique Identifier (GUID).

## Resources
[Bicep module](/code/01%20-%20Modules/modules/openAI.bicep)