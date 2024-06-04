# Network Segmentation
Segmentation is a model in which you take your networking footprint and create software defined perimeters using tools available in Microsoft Azure. You then set rules that govern the traffic from/to these perimeters so that you can have different security postures for various parts of your network. When you place different applications (or parts of a given application) into these perimeters, you can govern the communication between these segmented entities. If a part of your application stack is compromised, you'll be better able to contain the impact of this security breach, and prevent it from laterally spreading through the rest of your network. This ability is a key principle associated with the Zero Trust model published by Microsoft that aims to bring world-class security thinking to your organization

## Segmentation Patterns
When you operate on Azure, you have a wide and diverse set of segmentation options available to help you be protected.

![segmentation flow](/images/resource-flowchart.png)

1. **Subscription**: Subscriptions are a high-level construct, which provides platform powered separation between entities. It's intended to carve out boundaries between large organizations within a company. Communication between resources in different subscriptions needs to be explicitly provisioned.

2. **Virtual Network**: Virtual networks are created within a subscription in private address spaces. The networks provide network-level containment of resources, with no traffic allowed by default between any two virtual networks. Like subscriptions, any communication between virtual networks needs to be explicitly provisioned.

3. **Network Security Groups (NSG)**: NSGs are access control mechanisms for controlling traffic between resources within a virtual network as a layer 4 firewall. An NSG also controls traffic with external networks, such as the internet, other virtual networks, and so on. NSGs can take your segmentation strategy to a granular level by creating perimeters for a subnet, group of VMs, or even a single virtual machine.

4. **Azure Virtual Network Manager (AVNM)**: Azure Virtual Network Manager (AVNM) is a network management service that enables a central IT management team to manage virtual networks globally across subscriptions at scale. With AVNM, you can group multiple virtual networks and enforce predefined security admin rules, which should applied to the selected virtual networks at once. Similar to NSG, security admin rules created through AVNM also work as a layer 4 firewall, but security admin rules are evaluated first, before NSG.

5. **Application Security Groups (ASGs)**: ASGs provide control mechanisms similar to NSGs but are referenced with an application context. An ASG allows you to group a set of VMs under an application tag. It can define traffic rules that are then applied to each of the underlying VMs.

6. **Azure Firewall**: Azure Firewall is a cloud native stateful Firewall as a service. This firewall can be deployed in your virtual networks or in Azure Virtual WAN hub deployments for filtering traffic that flows between cloud resources, the Internet, and on-premise. You create rules or policies (using Azure Firewall or Azure Firewall Manager) specifying allow/deny traffic using layer 3 to layer 7 controls. You can also filter traffic that goes to the internet using both Azure Firewall and third parties. Direct some or all traffic through third-party security providers for advanced filtering and user protection.

The following patterns are common, when it comes to organizing your workload in Azure from a networking perspective. Each of these patterns provides a different type of isolation and connectivity. Choosing which model works best for your organization is a decision you should make based on your organization's needs. With each of these models, we describe how segmentation can be done using the above Azure Networking services.

It's also possible that the right design for your organization is something other than the ones we list here. And that outcome is expected, because there's no one size that fits everyone. You might end up using principles from across these patterns to create what's best for your organization. The Azure platform provides the flexibility and tooling you need.