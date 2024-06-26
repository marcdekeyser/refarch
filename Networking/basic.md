# Basic Azure Network Architecture (2 subnets)
## Overview
Within this pattern, all components of the workload are hosted within a single virtual network.
Network segmentation is performed only by Network Security Groups. 2 Subnets exist:
1. *Front-end subnet*: Used for deploying internet facing resources
2. *Back-end subnet*: used to deploy the non-internet facing resources

Caveats: 
- Only possible if you're operating solely in a single region, since a virtual network cannot span multiple regions.
- Security of front-end services is entirely on the application as no advantage is taken of native Azure services.

## Deploy this!
*Please note that the provided deployment is an example and should be tailored to your specific needs*  
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmarcdekeyser%2Frefarch%2Fmain%2Fbicep%2Fbasic%2Fdeploy.json)

### Bicep deployment
[Bicep References](../references.md#bicep)
* [Bicep Template](https://github.com/marcdekeyser/refarch/blob/main/bicep/basic)  

### Cost
The services used in this template are subject to their normal usage fees and charges. Learn more about the cost of individual services by visiting the [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/).

## Design methodology
[Find more here](/Topics/designmethodology.md)

## Built on Zero Trust
[Find more here](/Topics/zerotrust.md)

## Built on network-level segmentation patterns
[Find more here](/Topics/networksegmentation.md)

## Architecture
### Diagram
![Basic network architecture](/Networking/images/basic.png)

### Components
*Azure Region*
Azure operates in multiple datacenters around the world. These datacenters are grouped in to geographic regions, giving you flexibility in choosing where to build your applications.

You create Azure resources in defined geographic regions like 'West US', 'North Europe', or 'Southeast Asia'. You can [review the list of regions and their locations](https://azure.microsoft.com/regions/). Within each region, multiple datacenters exist to provide for redundancy and availability. This approach gives you flexibility as you design applications to create resources closest to your users and to meet any legal, compliance, or tax purposes.

[Azure geographies](https://azure.microsoft.com/en-us/explore/global-infrastructure/geographies/#overview)

*Azure virtual Network*
Azure Virtual Network is a service that provides the fundamental building block for your private network in Azure. An instance of the service (a virtual network) enables many types of Azure resources to securely communicate with each other, the internet, and on-premises networks. These Azure resources include virtual machines (VMs).

A virtual network is similar to a traditional network that you'd operate in your own datacenter. But it brings extra benefits of the Azure infrastructure, such as scale, availability, and isolation.

[Azure Virtual Network overview](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview)

*Azure Subnet*
Subnets enable you to segment the virtual network into one or more subnetworks and allocate a portion of the virtual network's address space to each subnet. You can then deploy Azure resources in a specific subnet. Just like in a traditional network, subnets allow you to segment your virtual network address space into segments that are appropriate for the organization's internal network. Segmentation improves address allocation efficiency. You can secure resources within subnets using Network Security Groups

*Network Security Group (NSG)*
You can use an Azure network security group to filter network traffic between Azure resources in an Azure virtual network. A network security group contains security rules that allow or deny inbound network traffic to, or outbound network traffic from, several types of Azure resources. For each rule, you can specify source and destination, port, and protocol.

[Azure Network Security Groups (NSG)](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)

*Azure Log Analytics workspace*
All networking logs are collected within a log analytics workspace