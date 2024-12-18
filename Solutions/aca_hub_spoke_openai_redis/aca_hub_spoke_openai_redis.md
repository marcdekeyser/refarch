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
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmarcdekeyser%2Frefarch%2Frefs%2Fheads%2Fmain%2Fcode%2Fsol_hubspoke_aca_openai_redis%2Fmain.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fmarcdekeyser%2Frefarch%2Frefs%2Fheads%2Fmain%2Fcode%2Fsol_hubspoke_aca_openai_redis%2Fmain.json)

### Deploy using bicep
For help on deploying bicep resourced please refer to [this page](/code/DeployBicep.md)
* [Bicep Template](https://github.com/marcdekeyser/refarch/blob/man/code/sol_hubspoke_aca_openai_redis/)  

### Parameters in main.bicep
- *appname*: Name of the workload
- *env*: Workload environment (Production, acceptance, test, development)
- *Location*: Location of the resources. Defaults to resourcegroup location
- *HUB vNET prefix*: CIDR prefix of the HUB vNET. Defaults to 10.2.0.0/16
- *HUB services subnet prefix*: CIDR prefix of the HUB services subnet. Defaults to 10.2.0.0/24
- *HUB bastion subnet prefix*: CIDR prefix of the HUB bastion subnet. Defaults to 10.2.1.0/24
- *HUB mangement subnet prefix*: CIDR prefix of the HUB management subnet. Defaults to 10.2.2.0/24
- *HUB runner agents subnet prefix*: CIDR prefix of the HUB runner agents subnet. Defaults to 10.2.3.0/24
- *ACA vNET prefix*: CIDR prefix of the AKS vNET. Defaults to 10.3.0.0/16
- *ACA container subnet prefix*: CIDR prefix of the AKS cluster subnet. Defaults to 10.3.0.0/24
- *ACA backend subnet prefix*: CIDR prefix of the AKS backend subnet. Defaults to 10.3.1.0/24
- *ACA services subnet prefix*: CIDR prefix of the AKS services subnet. Defaults to 10.3.2.0/24
- *ACA load balancer subnet prefix*: CIDR prefix of the AKS load balancer subnet. Defaults to 10.3.3.0/24
- *Virtual Machine SKU*: SKU for the management and runner agent virtual machines 
- *Virtual Machine Admin Username*: Username for the virtual machines.
- *Virtual Machine Admin Passowrd*: Password for the virtual machines.

## Design
![Foundational solution platform](/Solutions/aca_hub_spoke_openai_redis/images/sol_aca_hub_spoke_openai_redis.png)
*Diagram: Design diagram of the foundational solution*
[visio file](/Solutions/aca_hub_spoke_openai_redis/diagrams/sol_aca_hub_spoke_openai_redis.vsdx)

### Components
* **Virtual Network**: Foundational to our secure infrastructure we need a vNET to segment our networks
* **Subnet**: Multiple subnets are deployed in order to support segmenting the network. Each subnet is tied to a functionality:
- *Services*: Centralized subnet to host services such as keyvault or log analytics
- *aca*: subnet tdelegated to Azure container apps
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
* **Azure OpenAI**: Cognitive service deployed with GPT 3.5 Turbo
* **Redis Cache**: redis cahce provides an in-memory data store based on the redis software. 


