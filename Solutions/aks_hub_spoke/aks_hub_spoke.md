# Hub/spoke foundation
## Index
* [Description](#description)
* [Deploy to Azure](#deploy-to-azure)
* [Design](#design)
* [Components](#components)

## Description
This sample architecture aims to give you a headstart to deploying a secure and scalable environment within Azure. This design is *NOT* focused on a workload, but concentrates on the AKS cluster and related services itself. It integrates Azure services that deliver observality and provides a network topology that supports multi-regional growth (with some adjustments).

Business requirements influence the target architecture and it can vary between different application contexts. Consider this a starting point for preprod and prod stages.

## Deploy this 
*Please note that the provided deployment is an example and should be tailored to your specific needs* 

### Prerequisites
You'll need an active Azure subscription. If you do not have one you can create a [free Azure account](https://azure.microsoft.com/free/) before beginning. You will also require a resource group to deploy the resources into

### Need to know
The network security groups have not been configured with the appropriate rules. You will need to set these up manually.

A single management and runner agent machine is deployed of the sku B2. It's recommended to change the sku and deploy multiple for scalability and redudance.

### Deploy to Azure
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmarcdekeyser%2Frefarch%2Frefs%2Fheads%2Fmain%2Fcode%2Fsol_hubspoke_aks%2Fmain.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fmarcdekeyser%2Frefarch%2Frefs%2Fheads%2Fmain%2Fcode%2Fsol_hubspoke_aks%2Fmain.json)

### Deploy using bicep
For help on deploying bicep resourced please refer to [this page](/code/DeployBicep.md)
* [Bicep Template](https://github.com/marcdekeyser/refarch/blob/man/code/sol_hubspoke_aks/)  

### Parameters in main.bicep
- *Location*: Location of the resources. Defaults to resourcegroup location
- *HUB vNET prefix*: CIDR prefix of the HUB vNET. Defaults to 10.2.0.0/16
- *HUB services subnet prefix*: CIDR prefix of the HUB services subnet. Defaults to 10.2.0.0/24
- *HUB bastion subnet prefix*: CIDR prefix of the HUB bastion subnet. Defaults to 10.2.1.0/24
- *HUB mangement subnet prefix*: CIDR prefix of the HUB management subnet. Defaults to 10.2.2.0/24
- *HUB runner agents subnet prefix*: CIDR prefix of the HUB runner agents subnet. Defaults to 10.2.3.0/24
- *AKS vNET prefix*: CIDR prefix of the AKS vNET. Defaults to 10.3.0.0/16
- *AKS cluster subnet prefix*: CIDR prefix of the AKS cluster subnet. Defaults to 10.3.0.0/24
- *AKS backend subnet prefix*: CIDR prefix of the AKS backend subnet. Defaults to 10.3.1.0/24
- *AKS services subnet prefix*: CIDR prefix of the AKS services subnet. Defaults to 10.3.2.0/24
- *AKS load balancer subnet prefix*: CIDR prefix of the AKS load balancer subnet. Defaults to 10.3.3.0/24
- *PrincipleID*: Principle ID of the object to receive role assignment. **YOU NEED TO CHANGE THIS TO MATCH THE PRINCIPLE ID OF THE USER/GROUP/OBJECT THAT SHOULD RECEIVE THESE ROLE ASSIGNMENTS**
- *Management Virtual Machine Admin Username*: Set to azAdmin.
- *Management Virtual Machine Admin Passowrd*: Set to Welcome2024!. **YOU NEED TO CHANGE THIS TO A SECURE PASSWORD**
- *Runner Agent Virtual Machine Admin Username*: Set to azAdmin.
- *Runner Agent Virtual Machine Admin Passowrd*: Set to Welcome2024!. **YOU NEED TO CHANGE THIS TO A SECURE PASSWORD**

## Design
![Foundational solution platform](/Solutions/aks_hub_spoke/images/sol_aks_hub_spoke.png)
*Diagram: Design diagram of the foundational solution*
[visio file](/Solutions/aks_hub_spoke/Diagrams/sol_aks_hub_spoke.vsdx)

### Components
* **Virtual Network**: Foundational to our secure infrastructure we need a vNET to segment our networks
* **Subnet**: Multiple subnets are deployed in order to support segmenting the network. Each subnet is tied to a functionality:
- *Services*: Centralized subnet to host services such as keyvault or log analytics
- *aks*: subnet to host aks nodes in
- *loadbalancer*: load balancer should go here
- *back-end*: To host any storage, databases, or others
- *Services*: Centralized subnet to host services such as keyvault and the container registry
- *Bastion*: Used for hosting the bastion service.
- *Management*: Hosts the management virtual machine(s)
- *Runner agents*: Hosts the runned agent virtual machine(s). Necessary if we're using GitHub or other GIT solutions for deploying pipeline actions to the infrastructure.
- *Services*: Centralized subnet to host services such as log analytics
* **Network security group**: Used to control traffic flow between subnets
* **Keyvault**: Service to securely store and access secrets
* **Azure Monitor log analytics workspace**: 
* **Azure Bastion**: Azure bastion is a fully managed PaaS service to securely connect to virtual machines via private IP address. It protects these virtual machines from exposing RDP or SSH ports to the outside world, while still allowing access over these ports.
A public IP address is created to allow accessing bastion, and is secured by DDoS single IP protection.
* **Management virtual machine**: Since our resources are all private we need a way to manage them
* **Runner Agents virtual machine**: Since our resources are all private, we can't trigger pipeline actions to change them over the public internet. Runner agents solve this by connecting to the pipeline securely and executing the tasks on-behalf.
* **Azure Monitor log analytics workspace**: 
* **Azure Kubernetes Services**: Managed Kubernetes service
* **Azure Container registry**: Service to host your container images in Azure.
* **Private endpoints**: All services have public access disabled and private endpoints enabled
* **Azure private DNS**: Private DNS zones have been created and linked to the vNET to allow for resolution

### AKS settings
The AKS cluster will be deployed with the following settings:
* *Monitoring*: Container insights will be enabled and connected to the log analytics workspace
* *System Pool Size*: System Pool set to 'Cost-optimized'. These are B4 machines with no zone redundancy.
* *User Pool Size*: User Pool set to 'Cost-optimized'. These are B4 machines with no zone redundancy. Recommended to change for production workloads. Refer to the aks.bicep file for other options.
* *disable local accounts*: No local AKS accounts, so it can only be managed through Entra ID accounts
* *Public Network access*: Set to disabled so it's not publicly accessible
* *Private server*: Set to true so the AKS management API is only accesible through the vNET
* *Subnet*: Tied to the AKS subnet so nodes are deployed here
* *KeyVault secrets provider*: Set to enabled to allow using KeyVault secrets
* *load balancer SKU*: Set to standard
* *AKS Sku*: Set to standard (the paying version.)
* *Principle Type*: Type of principle to assign application roles to. Currently set to a user. Recommended to be changed to Group.
* Principle*: The users principle ID. You should change this!

Many more options exists for further customization. Please refer to aks.bicep for these parameters.

### Network topology
A hub and spoke network topology is used, deploying hub and spoke virtual networks that are connected through virtual network peering. There are several advantages to this topology:

* Network segmentation.
* Minimizes the direct exposure of resources to the public internet.
* Enables regional hub and spoke topologies. This network topology can be expanded towards the future and provides workload isolation.
* Support for workload that span multiple subscriptions.
* Extendible architecture. To accomodate new features or workloads, new spokes can be added instead of requiring a network redesign.
* Supports sharing resources accross networks.

### Compute for the AKS Cluster
Using AKS, each node pool maps to a virtual machine scale set. Each node in AKS is a Virtual Machine in a node pool. Consider using smaller VM sizes for the system node pool to minimize costs. Consider the following for the user node pool:

- Larger node sizes to pack as many pods on a node. This minimizes the footprint of services running on nodes
- Select the appropriate virtual machine size for workload requirement. This could be memory-optimized or GPU-accelerated nodes. For more information see [sizes for virtual machines in Azure](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview)
- It is recommended to deploy atleast two nodes. In this way the workloads running on the cluster have a high availability pattern with two replicates. You can change the node count within AKS without recreating the cluster.
- Plan the actual node sizes for your workloads based on the requirements you determined are needed.
- Assume workloads can consume up to 80% of each node when planning for capacity. The remaining 20% is reserved for AKS services
- Set the maximum pods per node based on your capacity planning. If you're in the process of establishing a capacity baseline, start with a value of 30 pods per node. Adjust the value based on the requirements of the workload, the node size, and possible IP constraints.

### Networking models
AKS supports multiple networking models including kubenet, CNI, and Azure CNI Overlay. The CNI models are the more advanced models, and are highly performant. When communicating between pods, the performance of CNI is similar to the performance of VMs in a virtual network. CNI also offers enhanced security control because it enables the use of Azure network policy. We recommend a CNI-based networking model.

In the non-overlay CNI model, every pod gets an IP address from the subnet address space. Resources within the same network (or peered resources) can access the pods directly through their IP address. Network Address Translation (NAT) isn't needed for routing that traffic.

More information:
- [Choosing a container networking interface network model](https://learn.microsoft.com/en-us/azure/aks/azure-cni-overlay#choosing-a-network-model-to-use)
- [Compare kubenet and Azure container networking interface network models](https://learn.microsoft.com/en-us/azure/aks/operator-best-practices-network#choose-the-appropriate-network-model)

