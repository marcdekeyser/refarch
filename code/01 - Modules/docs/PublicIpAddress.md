# Public IP Adress
## Parameters
* *Name*: **Required** - The name of the public IP adress
* *publicIPPrefixResourceId*: **Optional** - Resource ID of the Public IP Prefix object. This is only needed if you want your Public IPs created in a PIP Prefix.
* *publicIPAllocationMethod*: **Optional** - The public IP address allocation method. Can be Dynamic or Static.
* *skuName*: **Optional** - Name of a public IP address SKU. Can be Basic or Standard.
* *skuTier*: **Optional** -  Tier of a public IP address SKU. Can be Global or Regional.
* *zones*: **Optional** - A list of availability zones from which the IP allocated for the resource need to come from.
* *publicIPAddressVersion*: **Optional** - IP address version. Can be IPv4 or IPv6.
* *diagnosticStorageAccountId*: **Optional** - Resource ID of the diagnostic storage account.
* *diagnosticWorkspaceId*: **Optional** - Resource ID of the diagnostic log analytics workspace.
* *diagnosticEventHubAuthorizationRuleId*: **Optional** Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.
* *diagnosticEventHubName*: **Optional** - Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.
* *domainNameLabel*: **Optional** - The domain name label. The concatenation of the domain name label and the regionalized DNS zone make up the fully qualified domain name associated with the public IP address. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system.
* *fqdn*: **Optional** - The Fully Qualified Domain Name of the A DNS record associated with the public IP. This is the concatenation of the domainNameLabel and the regionalized DNS zone.
* *reverseFqdn*: **Optional** - The reverse FQDN. A user-visible, fully qualified domain name that resolves to this public IP address. If the reverseFqdn is specified, then a PTR DNS record is created pointing from the IP address in the in-addr.arpa domain to the reverse FQDN.
* *lock*: **Optional** - Specify the type of lock. Can be CanNotDelete, ReadOnly, or ''
* *location*: **Optional** Location for all resources.
* *tags*: **Optional** - Tags of the resource. Is an object
* *diagnosticLogCategoriesToEnable*: **Optional** - The name of logs that will be streamed. "allLogs" includes all possible logs for the resource. Can be allLogs, DDoSProtectionNotifications, DDoSMitigationFlowLogs, or DDoSMitigationReports. Defaults to allLogs
* *diagnosticMetricsToEnable*: **Optional** - The name of metrics that will be streamed. Can be AllMetrics.
* *diagnosticSettingsName*: **Optional** The name of the diagnostic setting, if deployed. If left empty, it defaults to "<resourceName>-diagnosticSettings".
* *ddosProtectionMode*: **Optional** - DDoS protection mode. see https://learn.microsoft.com/azure/ddos-protection/ddos-protection-sku-comparison#skus. Can be Enabled, Disabled, or VirtualNetworkInherited (recommended to atleast use Enabled).

## resource
[bicep module](/code/01%20-%20Modules/modules/pip.bicep)