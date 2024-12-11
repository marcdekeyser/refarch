# Network-level segmentation
## Overview
Segmentation is a model in which you take your networking footprint and create defined peimeters in Azure. You can then set rules that govern traffic from and to these perimeters so different security postures can be set for various parts of your network.

When you place different applications, or different parts of an application, into these perimeters you can control the flow of traffic between the segmented entities.

If part of your application stack is compromised, you'll be better able to contain the impact of the security breach, and prevent it from from laterally spreading through the rest of the network. This ability is a key principle associated with the Zero Trust security model.

## Segmentation patterns
Using Azure, you have a wide and diverse set of segmentation options available to help protect your environment

![Azure segmentation components](https://learn.microsoft.com/en-us/azure/architecture/networking/guide/images/resource-flowchart.png)

- **Subscription**: Subscriptions are a high-level construct, providing platform powered separation between entities. Subscriptions have the intent of carving out boundaries within the environment. Communications between resources in different subscriptions needs to be explicitly provisioned.
- **Virtual Network**: Virtual networks are created within a subscription in a private address space. The networks provide network-level containment of resources, with no traffic allowed between any two virtual networks (by default). Just as with subscriptions, communications between different virtual networks needs to be explicitly provisioned.
- **Network Security Groups (NSG)**: NSGs are access control mechanisms for controlling traffic between resources within a virtual network as a layer 4 firewall. An NSG also controls traffic with external networks, such as the internet, other virtual networks, and so on. NSGs can take your segmentation strategy to a granular level by creating perimeters for a subnet, group of VMs, or even a single virtual machine.
- **Azure Virtual Network Manager (AVNM)**: Azure Virtual Network Manager (AVNM) is a network management service that enables a central IT management team to manage virtual networks globally across subscriptions at scale. With AVNM, you can group multiple virtual networks and enforce predefined security admin rules, which should applied to the selected virtual networks at once. Similar to NSG, security admin rules created through AVNM also work as a layer 4 firewall, but security admin rules are evaluated first, before NSG
- **Application Security Groups (ASG)**: ASGs provide control mechanisms similar to NSGs but are referenced with an application context. An ASG allows you to group a set of VMs under an application tag. It can define traffic rules that are then applied to each of the underlying VMs.
- **Azure Firewall**: Azure Firewall is a cloud native stateful Firewall as a service. This firewall can be deployed in your virtual networks or in Azure Virtual WAN hub deployments for filtering traffic that flows between cloud resources, the Internet, and on-premise. You create rules or policies (using Azure Firewall or Azure Firewall Manager) specifying allow/deny traffic using layer 3 to layer 7 controls. You can also filter traffic that goes to the internet using both Azure Firewall and third parties. Direct some or all traffic through third-party security providers for advanced filtering and user protection.

There are a number of common segmantation patterns in organizing workloads within Azure from a networking perspective. Each of the patterns provide a different level of isolation and connectivity. Chooring the model which works best is a decision you need to make based on the needs of the organiszation.

It's also possible the right model for your organizations is not listed here. That's entirely to be expected as no one size truly fits all. 

### Pattern 1: Single virtual Network
#### Diagram
![Pattern 1 - Single virtual Network]()

### Pattern 2: Multiple virtual networks
#### Diagram
![Pattern 2 - Multiple virtual Networks]()

### Pattern 3: Multiple virtual networks with meshed peering
#### Diagram
![Pattern 3 - Multiple virtual networks with meshed peering]()

### Pattern 4: Hub And Spoke model
#### Diagram
![Pattern 4 - Hub And Spoke model]()