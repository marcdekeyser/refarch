# Public IP Adress
## Parameters
* *name*: **Required** - Name of the Network Security Group. Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore.
* *location*: **Required** - Azure Region where the resource will be deployed in
* *tags*: **Required** - Key-value pairs as tags, to identify the resource
* *securityRules*: **Optional** - Array of Security Rules to deploy to the Network Security Group. When not provided, an NSG including only the built-in roles will be deployed.
* *flushConnection*: **Optional** - When enabled, flows created from Network Security Group connections will be re-evaluated when rules are updates. Initial enablement will trigger re-evaluation. Network Security Group connection flushing is not available in all regions.
* *diagnosticStorageAccountId*: **Optional** - Resource ID of the diagnostic storage account.
* *diagnosticWorkspaceId*: **Optional** - Resource ID of the diagnostic log analytics workspace.
* *diagnosticEventHubAuthorizationRuleId*: **Optional** - Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.
* *diagnosticEventHubName*: **Optional** - Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.
* *diagnosticLogCategoriesToEnable*: **Optional** - The name of logs that will be streamed. "allLogs" includes all possible logs for the resource.
* *diagnosticSettingsName*: **Optional** - The name of the diagnostic setting, if deployed. If left empty, it defaults to "<resourceName>-diagnosticSettings".

## Resource
[Bicep module](/code/01%20-%20Modules/docs/nsg.md)