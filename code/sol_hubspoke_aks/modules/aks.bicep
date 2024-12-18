@description('Required. The name of the parent managed cluster. Required if the template is used in a standalone deployment.')
param clustername string

@description('Optional. Specifies the location of AKS cluster. It picks up Resource Group\'s location by default.')
param location string = resourceGroup().location

@description('Optional. Network plugin used for building the Kubernetes network.')
@allowed(['azure', 'kubenet'])
param networkPlugin string = 'azure'

@description('Optional. Specifies the network policy used for building Kubernetes network. - calico or azure.')
@allowed(['azure', 'calico'])
param networkPolicy string = 'azure'

@description('Optional. Specifies the DNS prefix specified when creating the managed cluster.')
param dnsPrefix string = clustername

@description('Optional. The name of the resource group for the managed resources of the AKS cluster.')
param nodeResourceGroupName string = ''

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

@description('Required. Id of the user or app to assign application roles.')
param principalId string

@description('Optional. The type of principal to assign application roles.')
@allowed(['Device', 'ForeignGroup', 'Group', 'ServicePrincipal', 'User'])
param principalType string = 'User'

@description('Optional. Kubernetes Version.')
param kubernetesVersion string = '1.29'

@description('Optional. Tier of a managed cluster SKU.')
@allowed([
  'Free'
  'Premium'
  'Standard'
])
param skuTier string = 'Standard'

@description('Optional. Network dataplane used in the Kubernetes cluster. Not compatible with kubenet network plugin.')
@allowed([
  'azure'
  'cilium'
])
param networkDataplane string?

@description('Optional. Network plugin mode used for building the Kubernetes network. Not compatible with kubenet network plugin.')
@allowed([
  'overlay'
])
param networkPluginMode string?

@description('Optional. Specifies the CIDR notation IP range from which to assign pod IPs when kubenet is used.')
param podCidr string?

@description('Optional. A CIDR notation IP range from which to assign service cluster IPs. It must not overlap with any Subnet IP ranges.')
param serviceCidr string?

@description('Optional. Specifies the IP address assigned to the Kubernetes DNS service. It must be within the Kubernetes service address range specified in serviceCidr.')
param dnsServiceIP string?

@description('Optional. Specifies the SSH RSA public key string for the Linux nodes.')
param sshPublicKey string?

@description('Conditional. Specifies the resource ID of connected application gateway. Required if `ingressApplicationGatewayEnabled` is set to `true`.')
param appGatewayResourceId string?

@description('Required. Resource ID of the monitoring log analytics workspace.')
param monitoringWorkspaceResourceId string

@description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set and networkRuleSetIpRules are not set.  Note, requires the \'acrSku\' to be \'Premium\'.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Optional. Specifies the sku of the load balancer used by the virtual machine scale sets used by nodepools.')
@allowed([
  'basic'
  'standard'
])
param loadBalancerSku string = 'standard'

@description('Optional. Specifies whether the webApplicationRoutingEnabled add-on is enabled or not.')
param webApplicationRoutingEnabled bool = true

@description('Optional. Tier of your Azure container registry.')
@allowed([
  'Basic'
  'Premium'
  'Standard'
])
param acrSku string = 'Standard'

@description('Optional. The name (as GUID) of the role assignment. If not provided, a GUID will be generated.')
param aksClusterRoleAssignmentName string?

import {agentPoolType} from 'br/public:avm/res/container-service/managed-cluster:0.4.1'
@description('Optional. Custom configuration of system node pool.')
param systemPoolConfig agentPoolType[]?

@description('Optional. Custom configuration of user node pool.')
param agentPoolConfig agentPoolType[]?

@description('Optional. Specifies whether the KeyvaultSecretsProvider add-on is enabled or not.')
param enableKeyvaultSecretsProvider bool = true

@description('Optional. If set to true, getting static credentials will be disabled for this cluster. This must only be used on Managed Clusters that are AAD enabled.')
param disableLocalAccounts bool = true

@allowed([
  'NodeImage'
  'None'
  'SecurityPatch'
  'Unmanaged'
])
@description('Optional. Auto-upgrade channel on the Node Os.')
param autoNodeOsUpgradeProfileUpgradeChannel string = 'NodeImage'

@allowed([
  'CostOptimised'
  'Standard'
  'HighSpec'
  'Custom'
])
@description('Optional. The System Pool Preset sizing.')
param systemPoolSize string = 'Standard'

@allowed([
  ''
  'CostOptimised'
  'Standard'
  'HighSpec'
  'Custom'
])

@description('Optional. The User Pool Preset sizing.')
param agentPoolSize string = ''

@description('Subnet the nodes will be deployed in')
param subnetresourceID string

var systemPoolsConfig = !empty(systemPoolConfig) ? systemPoolConfig :  [union({ name: 'npsystem', mode: 'System' }, nodePoolBase, nodePoolPresets[systemPoolSize])]

var agentPoolsConfig = !empty(agentPoolConfig) ? agentPoolConfig : empty(agentPoolSize) ? null : [union({ name: 'npuser', mode: 'User' }, nodePoolBase, nodePoolPresets[agentPoolSize])]

var aksClusterAdminRole = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  'b1ff04bb-8a4e-4dc4-8eb5-8693973ce19b'
)

var acrPullRole = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '7f951dda-4ed3-4680-a7ca-43fe172d538d'
)

// refer to https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/container-service/managed-cluster/agent-pool for all parameters
var nodePoolPresets = {
  CostOptimised: {
    vmSize: 'Standard_B4ms'
    count: 1
    minCount: 1
    maxCount: 3
    enableAutoScaling: true
    availabilityZones: []
    vnetSubnetResourceID: subnetresourceID
  }
  Standard: {
    vmSize: 'Standard_DS2_v2'
    count: 3
    minCount: 3
    maxCount: 5
    enableAutoScaling: true
    availabilityZones: [
      1
      2
      3
    ]
    vnetSubnetResourceID: subnetresourceID
  }
  HighSpec: {
    vmSize: 'Standard_D4s_v3'
    count: 3
    minCount: 3
    maxCount: 5
    enableAutoScaling: true
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    vnetSubnetResourceID: subnetresourceID
  }
}

var nodePoolBase = {
  osType: 'Linux'
  maxPods: 30
  type: 'VirtualMachineScaleSets'
  upgradeSettings: {
    maxSurge: '33%'
  }
}

module managedCluster 'br/public:avm/res/container-service/managed-cluster:0.4.1' = {
  name: '${uniqueString(deployment().name, location)}-managed-cluster'
  params: {
    name: clustername
    location: location
    nodeResourceGroup: nodeResourceGroupName
    networkDataplane: networkDataplane
    networkPlugin: networkPlugin
    networkPluginMode: networkPluginMode
    networkPolicy: networkPolicy
    podCidr: podCidr
    serviceCidr: serviceCidr
    dnsServiceIP: dnsServiceIP
    kubernetesVersion: kubernetesVersion
    sshPublicKey: sshPublicKey
    skuTier: skuTier
    appGatewayResourceId: appGatewayResourceId
    monitoringWorkspaceResourceId: monitoringWorkspaceResourceId
    publicNetworkAccess: publicNetworkAccess
    autoNodeOsUpgradeProfileUpgradeChannel: autoNodeOsUpgradeProfileUpgradeChannel
    enableKeyvaultSecretsProvider: enableKeyvaultSecretsProvider
    webApplicationRoutingEnabled: webApplicationRoutingEnabled
    disableLocalAccounts: disableLocalAccounts
    enablePrivateCluster: true
    loadBalancerSku: loadBalancerSku
    managedIdentities: {
      systemAssigned: true
    }
    diagnosticSettings: [
      {
        logCategoriesAndGroups: [
          {
            category: 'cluster-autoscaler'
            enabled: true
          }
          {
            category: 'kube-controller-manager'
            enabled: true
          }
          {
            category: 'kube-audit-admin'
            enabled: true
          }
          {
            category: 'guard'
            enabled: true
          }
          {
            category: 'kube-scheduler'
          }
          {
            category: 'kube-apiserver'
          }
        ]
        workspaceResourceId: monitoringWorkspaceResourceId
        metricCategories: [
          {
            category: 'AllMetrics'
            enabled: true
          }
        ]
      }
    ]
    primaryAgentPoolProfiles: systemPoolsConfig
    dnsPrefix: dnsPrefix
    agentPools: agentPoolsConfig
    enableTelemetry: enableTelemetry
    autoUpgradeProfileUpgradeChannel: 'stable'
    roleAssignments: [
      {
        name: aksClusterRoleAssignmentName
        principalId: principalId
        principalType: principalType
        roleDefinitionIdOrName: aksClusterAdminRole
      }
    ]
  }
}
