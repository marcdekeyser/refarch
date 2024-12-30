# Azure Kubernetes Service
## Parameters
### Cluster Settings
* *name*: **Optional** - Specifies the name of the AKS cluster.
* *enableVnetIntegration*: **Optional** - Specifies whether to enable API server VNET integration for the cluster or not.
* *virtualNetworkName*: **Optional** - Specifies the name of the existing virtual network.
* *systemAgentPoolSubnetName*: **Optional** - Specifies the name of the subnet hosting the worker nodes of the default system agent pool of the AKS cluster.
* *userAgentPoolSubnetName*: **Optional** - Specifies the name of the subnet hosting the worker nodes of the user agent pool of the AKS cluster.
* *podSubnetName*: **Optional** - Specifies the name of the subnet hosting the pods running in the AKS cluster.
* *apiServerSubnetName*: **Optional** - Specifies the name of the subnet delegated to the API server when configuring the AKS cluster to use API server VNET integration.
* managedIdentityName: **Required** - Specifies the name of the AKS user-defined managed identity.
* *dnsPrefix*: **Required** - Specifies the DNS prefix specified when creating the managed cluster.
* *networkPlugin*: **Required** - Specifies the network plugin used for building Kubernetes network. - azure or kubenet.
* *networkPluginMode*: Specifies the Network plugin mode used for building the Kubernetes network. - None or overlay
* *networkMode*: **Optional** -Specifies the network mode. This cannot be specified if networkPlugin is anything other than azure. - bridge or transparent.
* *networkPolicy*: Specifies the network policy used for building Kubernetes network. - Azure, Calico, Cilium or none.
* *networkDataplane*: Specifies the network dataplane used in the Kubernetes cluster. - Azure or Cilium
* *podCidr*: Specifies the CIDR notation IP range from which to assign pod IPs when kubenet is used.
* *serviceCidr*: A CIDR notation IP range from which to assign service cluster IPs. It must not overlap with any Subnet IP ranges.
* *dnsServiceIP*: Specifies the IP address assigned to the Kubernetes DNS service. It must be within the Kubernetes service address range specified in serviceCidr.
* *loadBalancerSku*: Specifies the sku of the load balancer used by the virtual machine scale sets used by nodepools.
* *loadBalancerBackendPoolType*: Specifies the type of the managed inbound Load Balancer BackendPool.
* *advancedNetworking*: Specifies Advanced Networking profile for enabling observability on a cluster. Note that enabling advanced networking features may incur additional costs. For more information see aka.ms/aksadvancednetworking.
* *outboundType*: Specifies outbound (egress) routing method. - Loadbalancer, managedNATGateway, UserAssignedNATGateway, userDefinedRouting.
* *skuTier*: Specifies the tier of a managed cluster SKU. - Free, Standard, Premium
* *kubernetesVersion*: Specifies the version of Kubernetes specified when creating the managed cluster.
* *adminUsername*: Specifies the administrator username of Linux virtual machines.
* *sshPublicKey*: Specifies the SSH RSA public key string for the Linux nodes.
* *aadProfileTenantId*: Specifies the tenant id of the Azure Active Directory used by the AKS cluster for authentication.
* *aadProfileAdminGroupObjectIDs*: Specifies the AAD group object IDs that will have admin role of the cluster.
* *nodeOSUpgradeChannel*: Specifies the node OS upgrade channel. NodeImage, None, SecurityPatch, Unmanaged.
* *upgradeChannel*: Specifies the upgrade channel for auto upgrade. rapid, stable, patch, node-image, none.
* *enablePrivateCluster*: Specifies whether to create the cluster as a private cluster or not.
* *privateDNSZone*: Specifies the Private DNS Zone mode for private cluster. When the value is equal to None, a Public DNS Zone is used in place of a Private DNS Zone
* *enablePrivateClusterPublicFQDN*: Specifies whether to create additional public FQDN for private cluster or not.
* *aadProfileManaged*: Specifies whether to enable managed AAD integration.
* *aadProfileEnableAzureRBAC*: Specifies whether to  to enable Azure RBAC for Kubernetes authorization.
* *userId*: Specifies the object id of an Azure Active Directory user. In general, this the object id of the system administrator who deploys the Azure resources.
* *workspaceId*: Specifies the resource id of the Log Analytics workspace.
* *location*: Specifies the location.
* *tags: Specifies the resource tags.
* *defenderSecurityMonitoringEnabled*: Specifies whether to enable Defender threat detection. The default value is false.
* *workloadIdentityEnabled*: Specifies whether to enable Workload Identity. The default value is false.

### System agent pool parameters
* *systemAgentPoolName*: Specifies the unique name of of the system node pool profile in the context of the subscription and resource group.
* *systemAgentPoolVmSize*: Specifies the vm size of nodes in the system node pool.
* *systemAgentPoolOsDiskSizeGB*: Specifies the OS Disk Size in GB to be used to specify the disk size for every machine in the system agent pool. If you specify 0, it will apply the default osDisk size according to the vmSize specified.
* *systemAgentPoolOsDiskType*: Specifies the OS disk type to be used for machines in a given agent pool. Allowed values are \'Ephemeral\' and \'Managed\'. If unspecified, defaults to \'Ephemeral\' when the VM supports ephemeral OS and has a cache disk larger than the requested OSDiskSizeGB. Otherwise, defaults to \'Managed\'. May not be changed after creation. - Managed or Ephemeral
* *systemAgentPoolAgentCount*: Specifies the number of agents (VMs) to host docker containers in the system node pool. Allowed values must be in the range of 1 to 100 (inclusive). The default value is 1.
* *systemAgentPoolOsType*: Specifies the OS type for the vms in the system node pool. Choose from Linux and Windows. Default to Linux.
* *systemAgentPoolOsSKU*: Specifies the OS SKU used by the system agent pool. If not specified, the default is Ubuntu if OSType=Linux or Windows2019 if OSType=Windows. And the default Windows OSSKU will be changed to Windows2022 after Windows2019 is deprecated.
* *systemAgentPoolMaxPods*: Specifies the maximum number of pods that can run on a node in the system node pool. The maximum number of pods per node in an AKS cluster is 250. The default maximum number of pods per node varies between kubenet and Azure CNI networking, and the method of cluster deployment.
* *systemAgentPoolMaxCount*: Specifies the maximum number of nodes for auto-scaling for the system node pool.
* *systemAgentPoolMinCount*: Specifies the minimum number of nodes for auto-scaling for the system node pool.
* *systemAgentPoolEnableAutoScaling*: Specifies whether to enable auto-scaling for the system node pool.
* *systemAgentPoolScaleSetPriority*: Specifies the virtual machine scale set priority in the system node pool:  Spot or Regular.
* *systemAgentPoolScaleSetEvictionPolicy*: Specifies the ScaleSetEvictionPolicy to be used to specify eviction policy for spot virtual machine scale set. Default to Delete. Allowed values are Delete or Deallocate.
* *systemAgentPoolNodeLabels*: Specifies the Agent pool node labels to be persisted across all nodes in the system node pool.
* *systemAgentPoolNodeTaints: Specifies the taints added to new nodes during node pool create and scale. For example, key=value: NoSchedule.
* systemAgentPoolKubeletDiskType: Determines the placement of emptyDir volumes, container runtime data root, and Kubelet ephemeral storage.
* *systemAgentPoolType*: Specifies the type for the system node pool:  VirtualMachineScaleSets or AvailabilitySet
* *systemAgentPoolAvailabilityZones*: Specifies the availability zones for the agent nodes in the system node pool. Requirese the use of VirtualMachineScaleSets as node pool type.
* *systemAgentPoolScaleDownMode*: Specified the scale down mode that effects the cluster autoscaler behavior. If not specified, it defaults to Delete.
* *systemAgentPoolSpotMaxPrice*: Possible values are any decimal value greater than zero or -1 which indicates the willingness to pay any on-demand price. For more details on spot pricing, see spot VMs pricing

### User agent pool parameters
* *userAgentPoolName*: Specifies the unique name of of the user node pool profile in the context of the subscription and resource group.
* *userAgentPoolVmSize*: Specifies the vm size of nodes in the user node pool.
* *userAgentPoolOsDiskSizeGB*: Specifies the OS Disk Size in GB to be used to specify the disk size for every machine in the system agent pool. If you specify 0, it will apply the default osDisk size according to the vmSize specified..
* *userAgentPoolOsDiskType*: Specifies the OS disk type to be used for machines in a given agent pool. Allowed values are \'Ephemeral\' and \'Managed\'. If unspecified, defaults to \'Ephemeral\' when the VM supports ephemeral OS and has a cache disk larger than the requested OSDiskSizeGB. Otherwise, defaults to \'Managed\'. May not be changed after creation. - Managed or 
* *userAgentPoolAgentCount*: Specifies the number of agents (VMs) to host docker containers in the user node pool. Allowed values must be in the range of 1 to 100 (inclusive). The default value is 1.
* *userAgentPoolOsType*: Specifies the OS type for the vms in the user node pool. Choose from Linux and Windows. Default to Linux.
* *userAgentPoolOsSKU*: Specifies the OS SKU used by the system agent pool. If not specified, the default is Ubuntu if OSType=Linux or Windows2019 if OSType=Windows. And the default Windows OSSKU will be changed to Windows2022 after Windows2019 is deprecated.
* *userAgentPoolMaxPods*: Specifies the maximum number of pods that can run on a node in the user node pool. The maximum number of pods per node in an AKS cluster is 250. The default maximum number of pods per node varies between kubenet and Azure CNI networking, and the method of cluster deployment.
* *userAgentPoolMaxCount*: Specifies the maximum number of nodes for auto-scaling for the user node pool.
* *userAgentPoolMinCount*: Specifies the minimum number of nodes for auto-scaling for the user node pool.
* *userAgentPoolEnableAutoScaling*: Specifies whether to enable auto-scaling for the user node pool.
* *userAgentPoolScaleSetPriority*: Specifies the virtual machine scale set priority in the user node pool:  Spot or Regular.
* *userAgentPoolScaleSetEvictionPolicy*: Specifies the ScaleSetEvictionPolicy to be used to specify eviction policy for spot virtual machine scale set. Default to Delete. Allowed values are Delete or Deallocate.
* *userAgentPoolNodeLabels*: Specifies the Agent pool node labels to be persisted across all nodes in the user node pool.
* *userAgentPoolNodeTaints*: Specifies the taints added to new nodes during node pool create and scale. For example, key=value: NoSchedule.
* *userAgentPoolKubeletDiskType*: Determines the placement of emptyDir volumes, container runtime data root, and Kubelet ephemeral storage.
* *userAgentPoolType*: Specifies the type for the user node pool:  VirtualMachineScaleSets or AvailabilitySet
* *userAgentPoolAvailabilityZones*: Specifies the availability zones for the agent nodes in the user node pool. Requirese the use of VirtualMachineScaleSets as node pool type.
* *userAgentPoolScaleDownMode*: Specified the scale down mode that effects the cluster autoscaler behavior. If not specified, it defaults to Delete.
* *userAgentPoolSpotMaxPrice*: Possible values are any decimal value greater than zero or -1 which indicates the willingness to pay any on-demand price. For more details on spot pricing, see spot VMs pricing

### Add-ons
* *httpApplicationRoutingEnabled*: Specifies whether the httpApplicationRouting add-on is enabled or not.
* *istioServiceMeshEnabled*: Specifies whether the Istio Service Mesh add-on is enabled or not.
* *istioIngressGatewayEnabled*: Specifies whether the Istio Ingress Gateway is enabled or not.
* *kedaEnabled*: Specifies whether the Kubernetes Event-Driven Autoscaler (KEDA) add-on is enabled or not.
* *daprEnabled*: Specifies whether the Dapr extension is enabled or not.
* *daprHaEnabled*: Enable high availability (HA) mode for the Dapr control plane
* *fluxGitOpsEnabled*: Specifies whether the Flux V2 extension is enabled or not.
* *verticalPodAutoscalerEnabled*: Specifies whether the Vertical Pod Autoscaler is enabled or not.
* *aciConnectorLinuxEnabled*: Specifies whether the aciConnectorLinux add-on is enabled or not.
* *azurePolicyEnabled*: Specifies whether the azurepolicy add-on is enabled or not.
* *azureKeyvaultSecretsProviderEnabled*: Specifies whether the Azure Key Vault Provider for Secrets Store CSI Driver addon is enabled or not.
* *kubeDashboardEnabled*: Specifies whether the kubeDashboard add-on is enabled or not.
* *podIdentityProfileEnabled*: Specifies whether the pod identity addon is enabled..
* *oidcIssuerProfileEnabled*: Specifies whether the OIDC issuer is enabled.

### Auto-scaler parameters
* *autoScalerProfileScanInterval*: Specifies the scan interval of the auto-scaler of the AKS cluster.
* *autoScalerProfileScaleDownDelayAfterAdd*: Specifies the scale down delay after add of the auto-scaler of the AKS cluster.
* *autoScalerProfileScaleDownDelayAfterDelete*: Specifies the scale down delay after delete of the auto-scaler of the AKS cluster.
* *autoScalerProfileScaleDownDelayAfterFailure*: Specifies scale down delay after failure of the auto-scaler of the AKS cluster.
* *autoScalerProfileScaleDownUnneededTime*: Specifies the scale down unneeded time of the auto-scaler of the AKS cluster.
* *autoScalerProfileScaleDownUnreadyTime*: Specifies the scale down unready time of the auto-scaler of the AKS cluster.
* *autoScalerProfileUtilizationThreshold*: Specifies the utilization threshold of the auto-scaler of the AKS cluster.
* *autoScalerProfileMaxGracefulTerminationSec*: Specifies the max graceful termination time interval in seconds for the auto-scaler of the AKS cluster.
* *autoScalerProfileExpander*: Specifies the type of node pool expander to be used in scale up. Possible values:  most-pods, random, least-waste, priority.

### CSI Driver
* *blobCSIDriverEnabled*: Specifies whether to enable the Azure Blob CSI Driver. The default value is false.
* *diskCSIDriverEnabled*: Specifies whether to enable the Azure Disk CSI Driver. The default value is true.
* *fileCSIDriverEnabled*: Specifies whether to enable the Azure File CSI Driver. The default value is true.

### Snapshot and image controller
* *snapshotControllerEnabled*: Specifies whether to enable the Snapshot Controller. The default value is true.
* *imageCleanerEnabled*: Specifies whether to enable ImageCleaner on AKS cluster. The default value is false.
* *imageCleanerIntervalHours*: Specifies whether ImageCleaner scanning interval in hours.
* nodeRestrictionEnabled: Specifies whether to enable Node Restriction. The default value is false.

### Monitoring
* *containerInsights: Specifies the Azure Monitor Container Insights Profile for Kubernetes Events, Inventory and Container stdout & stderr logs etc. See aka.ms/AzureMonitorContainerInsights for an overview.
* *prometheusAndGrafanaEnabled*: Specifies whether to create or not Azure Monitor managed service for Prometheus and Azure Managed Grafana resources.
* *metricAnnotationsAllowList*: Specifies a comma-separated list of additional Kubernetes label keys that will be used in the resource labels metric.
* *metricLabelsAllowlist*: Specifies a comma-separated list of Kubernetes annotations keys that will be used in the resource labels metric.

* *ipFamilies*: Specifies the IP families are used to determine single-stack or dual-stack clusters. For single-stack, the expected value is IPv4. For dual-stack, the expected values are IPv4 and IPv6.

### NGINX
* *webAppRoutingEnabled*: Specifies whether the managed NGINX Ingress Controller application routing addon is enabled.
param webAppRoutingEnabled bool = true
* *nginxDefaultIngressControllerType*: Specifies the ingress type for the default NginxIngressController custom resource
* *dnsZoneName*: Specifies the name of the public DNS zone used by the managed NGINX Ingress Controller, when enabled.
* *dnsZoneResourceGroupName*: Specifies the resource group name of the public DNS zone used by the managed NGINX Ingress Controller, when enabled.

## Resources
[Bicep Module](/code/01%20-%20Modules/modules/aks.bicep)