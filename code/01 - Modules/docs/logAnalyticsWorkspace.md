# Log analytics workspace
## Parameters
* *name*: Required. Name of the Log Analytics Workspace Service. It must be between 4 and 63 characters and can contain only letters, numbers and "-". The "-" should not be the first or the last symbol
* *location*: Required. Azure region where the resources will be deployed in
* *tags*: Optional. Tags for the resource
* *serviceTier*: Optional. Service Tier: PerGB2018, Free, Standalone, PerGB or PerNode.
* *dataRetention*: Optional, default 90. Number of days data will be retained for.
* *publicNetworkAccessForIngestion*: Optional. The network access type for accessing Log Analytics ingestion.
* *publicNetworkAccessForQuery*: Optional. The network access type for accessing Log Analytics query.
* *useResourcePermissions*: Optional. Set to \'true\' to use resource or workspace permissions and \'false\' (or leave empty) to require workspace permissions.

## Resources
[Bicep module](/code/01%20-%20Modules/modules/logAnalyticsWorkspace.bicep)