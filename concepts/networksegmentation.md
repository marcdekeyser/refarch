# Network-level segmentation

## Index
* [Overview](#overview)
* [Segmentation patterns](#segmentation-patterns)
* [Pattern 1 - Single virtual network](#pattern-1-single-virtual-network)
* [Pattern 2 - Multiple virtual network](#pattern-2-multiple-virtual-network)
* [Pattern 3 - Meshed virtual network](#pattern-3-multiple-virtual-networks-with-meshed-peering)
* [Pattern 4 - Hub and spoke virtual network](#pattern-4-hub-and-spoke-model)

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
In this pattern all components of a workload are inside of a single virtual region. The entities most likely used for segmentation in this scenario are either Network Security Groups or Application Security Groups. The choice of which depends on if you want to refer to you segments as network subnets, or application groups.

#### Diagram
![Pattern 1 - Single virtual Network](/concepts/images/networkingpattern1.png)
[visio file](/concepts/diagrams/networkingpattern1.vsdx)

In this setup you have one Virtual Network, with 3 subnets to place entities of the workload. Network Security groups would be used to control the flow of traffic between subnets (Front-end can talk to business logic, business logic can talk to back-end, front-end cannot talk to back-end.)

#### Deploy this!
*Please note that the provided deployment is an example and should be tailored to your specific needs*  
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmarcdekeyser%2Frefarch%2Fmain%2Fcode%2FNetworkPattern1%2Fmain.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fmarcdekeyser%2Frefarch%2Fmain%2Fcode%2FNetworkPattern1%2Fmain.json)

#### Bicep deployment
For help on deploying bicep resourced please refer to [this page](/code/DeployBicep.md)
* [Bicep Template](https://github.com/marcdekeyser/refarch/blob/man/code/NetworkPattern1/)  

### Pattern 2: Multiple virtual network
Like pattern one the components of a workload are contained within a single virtual region. Multiple workloads each have their own virtual network to create segmentation. No communication is possible between the workloads directly (other than possibly routing over the internet)

#### Diagram
![Pattern 2 - Multiple virtual Networks](/concepts/images/networkingpattern2.png)
[visio file](/concepts/diagrams/networkingpattern2.vsdx)

#### Deploy this!
*Please note that the provided deployment is an example and should be tailored to your specific needs*  
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmarcdekeyser%2Frefarch%2Fmain%2Fcode%2FNetworkPattern2%2Fmain.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fmarcdekeyser%2Frefarch%2Fmain%2Fcode%2FNetworkPattern2%2Fmain.json)

#### Bicep deployment
For help on deploying bicep resourced please refer to [this page](/code/DeployBicep.md)
* [Bicep Template](https://github.com/marcdekeyser/refarch/blob/man/code/NetworkPattern2/)  

### Pattern 3: Multiple virtual networks with meshed peering
Pattern 3 extends on the previous two patterns, wher you now have multiple virtual networks with peering connections. These connections make it possible for each virtual network to talk to the other virtual networks. This could be a good pattern for when multiple workloads are present that need to be able to communication with each other, or multiple regions within Azure are needed (not represented in the diagram). The network or application security groups should be configured to ensure traffic flows as expected and wanted.

#### Diagram
![Pattern 3 - Multiple virtual networks with meshed peering](/concepts/images/networkingpattern3.png)
[visio file](/concepts/diagrams/networkingpattern3.vsdx)

#### Deploy this!
*Please note that the provided deployment is an example and should be tailored to your specific needs*  
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmarcdekeyser%2Frefarch%2Fmain%2Fcode%2FNetworkPattern3%2Fmain.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fmarcdekeyser%2Frefarch%2Fmain%2Fcode%2FNetworkPattern3%2Fmain.json)

#### Bicep deployment
For help on deploying bicep resourced please refer to [this page](/code/DeployBicep.md)
* [Bicep Template](https://github.com/marcdekeyser/refarch/blob/man/code/NetworkPattern3/)  

### Pattern 4: Hub And Spoke model
Unlike pattern 3, where all virtual networks can communicate with each other, in pattern for there is no mesh peering. And because peering is not transitive, only virtual network 1 and 2 can talk with virtual network 3, but not with each other. Using a routing entity, such as Azure Firewall, virtual network 1 and 2 could communicate with each other by routing all traffic over virtual network 3. This allows for the centralization of security postures at the hub (virtual network 3 in this case). This way the hub segments and governs the traffic between virtual networks in a scalable way. 

An added benefit of this pattern is that, as your network topology grows, the security posture overhead does not grow (except in the case of expansion to a new region, where you would setup a new hub).

The recommended Azure cloud native segmentation control is Azure Firewall, which works accross virtual networks and subscriptions to control traffic flow using layer 3 to 7 controls. You can fully define what your communication controls look like (per subnet and even outgoing internet traffic). When you have multiple Azure Firewall instances, you can use Azure Firewall Manager to centrally manage policies across multiple Azure Firewalls and to enable further customization of local polices.

#### Diagram
![Pattern 4 - Hub And Spoke model](/concepts/images/networkingpattern4.png)
[visio file](/concepts/diagrams/networkingpattern4.vsdx)

#### Deploy this!
*Please note that the provided deployment is an example and should be tailored to your specific needs*  
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmarcdekeyser%2Frefarch%2Fmain%2Fcode%2FNetworkPattern4%2Fmain.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fmarcdekeyser%2Frefarch%2Fmain%2Fcode%2FNetworkPattern4%2Fmain.json)

#### Bicep deployment
For help on deploying bicep resourced please refer to [this page](/code/DeployBicep.md)
* [Bicep Template](https://github.com/marcdekeyser/refarch/blob/man/code/NetworkPattern4/)  