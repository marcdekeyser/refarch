# Application Gateway
## Parameters
* *name*: **Required** - Name of the Application Gateway.
* *location*: **Required** - Location for all resources.
* *userAssignedIdentities*: **Required** - The ID(s) to assign to the resource.
* *authenticationCertificates*: **Required** - Authentication certificates of the application gateway resource.
* *autoscaleMaxCapacity*: **Required** - Upper bound on number of Application Gateway capacity.
* *autoscaleMinCapacity*: **Required** - Lower bound on number of Application Gateway capacity.
* *backendAddressPools*: **Required** - Backend address pool of the application gateway resource.
* *backendHttpSettingsCollection*: **Required** - Backend http settings of the application gateway resource.
* *customErrorConfigurations*: **Required** - Custom error configurations of the application gateway resource.
* *enableFips*: **Required** - Whether FIPS is enabled on the application gateway resource.
* *enableHttp2*: **Required** - Whether HTTP2 is enabled on the application gateway resource.
* *firewallPolicyId*: **Required** - The resource ID of an associated firewall policy. Should be configured for security reasons.
* *frontendIPConfigurations*: **Required** - Frontend IP addresses of the application gateway resource.
* *frontendPorts*: **Required** - Frontend ports of the application gateway resource.
* *gatewayIPConfigurations*: **Required** - Subnets of the application gateway resource.
* *enableRequestBuffering*: **Required** - Enable request buffering.
* *enableResponseBuffering*: **Required** - Enable response buffering.
* *httpListeners*: **Required** - Http listeners of the application gateway resource.
* *loadDistributionPolicies*: **Required** - Load distribution policies of the application gateway resource.
* *privateLinkConfigurations*: **Required** - PrivateLink configurations on application gateway.
* *probes*: **Required** - Probes of the application gateway resource.
* *redirectConfigurations*: **Required** - Redirect configurations of the application gateway resource.
* *requestRoutingRules*: **Required** - Request routing rules of the application gateway resource.
* *rewriteRuleSets*: **Required** - Rewrite rules for the application gateway resource.
* *sku*: **Required** - The name of the SKU for the Application Gateway.
* *capacity*: **Required** - The number of Application instances to be configured.
* *sslCertificates*: **Required** - SSL certificates of the application gateway resource.
* *sslPolicyCipherSuites*: **Required** - Ssl cipher suites to be enabled in the specified order to application gateway.
* *sslPolicyMinProtocolVersion*: **Required** - Ssl protocol enums. For security reasons you should select TLSv1.2 or higher.
* *sslPolicyName*: **Required** - Ssl predefined policy name enums.
* *sslPolicyType*: **Required** - Type of Ssl Policy.
* *sslProfiles*: **Required** - SSL profiles of the application gateway resource.
* *trustedClientCertificates*: **Required** - Trusted client certificates of the application gateway resource.
* *trustedRootCertificates*: **Required** - Trusted Root certificates of the application gateway resource.
* *urlPathMaps*: **Required** - URL path map of the application gateway resource.
* *webApplicationFirewallConfiguration*: **Required** - Application gateway web application firewall configuration. Should be configured for security reasons.
* *zones*: **Required** - A list of availability zones denoting where the resource needs to come from.
* *diagnosticStorageAccountId*: **Required** - Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.
* *diagnosticWorkspaceId*: **Required** - Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.
* *diagnosticEventHubAuthorizationRuleId*: **Required** - Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.
* *diagnosticEventHubName*: **Required** - Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.
* *diagnosticLogCategoriesToEnable*: **Required** - The name of logs that will be streamed. "allLogs" includes all possible logs for the resource.
* *diagnosticMetricsToEnable*: **Required** - The name of metrics that will be streamed.

## Resources
[Bicep Module](/code/01%20-%20Modules/modules/applicationGateway.bicep)