# Container Registry
## Parameters
* *name*: **Required** - Name of your Azure container registry.
* *acrAdminUserEnabled*: **Optional** - Enable admin user that have push / pull permission to the registry.
* *location*: **Optional** - Location for all resources.
* *acrSku*: **Optional** - Tier of your Azure container registry.
* *exportPolicyStatus*: **Optional** - The value that indicates whether the export policy is enabled or not.
* *quarantinePolicyStatus*: **Optional** - The value that indicates whether the quarantine policy is enabled or not.
* *trustPolicyStatus*: **Optional** - The value that indicates whether the trust policy is enabled or not.
* *retentionPolicyStatus*: **Optional** - The value that indicates whether the retention policy is enabled or not.
* *retentionPolicyDays*: **Optional** - The number of days to retain an untagged manifest after which it gets purged.
* *azureADAuthenticationAsArmPolicyStatus*: **Optional** - The value that indicates whether the policy for using ARM audience token for a container registr is enabled or not. Default is enabled.
* *softDeletePolicyStatus*: **Optional** - Soft Delete policy status. Default is disabled.
* *softDeletePolicyDays*: **Optional** - The number of days after which a soft-deleted item is permanently deleted.
* *dataEndpointEnabled*: **Optional** - Enable a single data endpoint per region for serving data. Not relevant in case of disabled public access. Note, requires the \'acrSku\' to be \'Premium\'.
* *publicNetworkAccess*: **Optional** - Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set and networkRuleSetIpRules are not set.  Note, requires the \'acrSku\' to be \'Premium\'.'
* *networkRuleBypassOptions*: **Optional** - Whether to allow trusted Azure services to access a network restricted registry.
* *networkRuleSetDefaultAction*: **Optional** - The default action of allow or deny when no other rules match.
* *networkRuleSetIpRules*: **Optional** - The IP ACL rules. Note, requires the \'acrSku\' to be \'Premium\'.
* *privateEndpoints*: **Optional** - Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible. Note, requires the \'acrSku\' to be \'Premium\'.
* *zoneRedundancy*: **Optional** - Whether or not zone redundancy is enabled for this container registry.
* *systemAssignedIdentity*: **Optional** - Enables system assigned managed identity on the resource.
* *userAssignedIdentities*: **Optional** - The ID(s) to assign to the resource.
* *tags*: **Optional** - Tags of the resource.
* *diagnosticLogCategoriesToEnable*: **Optional** - The name of logs that will be streamed. "allLogs" includes all possible logs for the resource.
* *diagnosticMetricsToEnable*: **Optional** - The name of metrics that will be streamed.
* *diagnosticStorageAccountId*: **Optional** - Resource ID of the diagnostic storage account.
* *diagnosticWorkspaceId*: **Optional** - Resource ID of the diagnostic log analytics workspace.
* *diagnosticEventHubAuthorizationRuleId*: **Optional** - Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.
* *diagnosticEventHubName*: **Optional** - Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.
* *diagnosticSettingsName*: **Optional** - The name of the diagnostic setting, if deployed. If left empty, it defaults to "<resourceName>-diagnosticSettings".
* *anonymousPullEnabled*: **Optional** - Enables registry-wide pull from unauthenticated clients. It\'s in preview and available in the Standard and Premium service tiers.
* *cMKKeyVaultResourceId*: **Optional** - The resource ID of a key vault to reference a customer managed key for encryption from. Note, CMK requires the \'acrSku\' to be \'Premium\'.
* *cMKKeyName*: **Optional** - The name of the customer managed key to use for encryption. Note, CMK requires the \'acrSku\' to be \'Premium\'.
* *cMKKeyVersion*: **Optional** - The version of the customer managed key to reference for encryption. If not provided, the latest key version is used.
* *cMKUserAssignedIdentityResourceId*: Conditional. User assigned identity to use when fetching the customer managed key. Note, CMK requires the \'acrSku\' to be \'Premium\'. Required if \'cMKKeyName\' is not empty.
* *agentPoolName*: **Optional** - The name of the agent pool. This agent pool will be used to build docker image to be deployed.
* *agentPoolCount*: **Optional** - The number of agents in the agent pool.
* *agentPoolTier*: **Optional** - The tier of the agent pool.
* *agentPoolSubnetId*: The resource ID of the subnet to which the agent pool will be connected.

## Resources
[Bicep Module](/code/01%20-%20Modules/modules/containerRegistry.bicep)