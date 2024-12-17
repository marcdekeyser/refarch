# All in one foundation
## Index
* [Description](#description)
* [Deploy to Azure](#deploy-to-azure)
* [Design](#design)
* [Components](#components)
* [AKS Settings(#aks-settings)

## Description
This sample component aims to give you a headstart to deploying a secure and scalable environment within Azure.  This is not meant to be a full deployment of your environment, but a 'piece of the puzzle' in centralizing different services in a 'hub and spoke' design pattern. 

## Deploy this 
*Please note that the provided deployment is an example and should be tailored to your specific needs* 

### Prerequisites
You'll need an active Azure subscription. If you do not have one you can create a [free Azure account](https://azure.microsoft.com/free/) before beginning. A resource group is required to deploy this solution in to.

### Need to know
The network security groups have not been configured with the appropriate rules. You will need to set these up manually.

### Deploy to Azure
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmarcdekeyser%2Frefarch%2Frefs%2Fheads%2Fmain%2Fcode%2Fcomp_aks%2Fmain.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fmarcdekeyser%2Frefarch%2Frefs%2Fheads%2Fmain%2Fcode%2Fcomp_aks%2Fmain.json)

### Deploy using bicep
For help on deploying bicep resourced please refer to [this page](/code/DeployBicep.md)
* [Bicep Template](https://github.com/marcdekeyser/refarch/blob/man/code/comp_aks/)  

## Design
![Foundational solution platform](/components/images/comp_aks.png)
*Diagram: Design diagram of the hub component*
[visio file](/components/diagrams/comp_aks.vsdx)

### Components
* **Virtual Network**: Foundational to our secure infrastructure we need a vNET to segment our networks
* **Subnet**: Multiple subnets are deployed in order to support segmenting the network. Each subnet is tied to a functionality:
- *Services*: Centralized subnet to host services such as keyvault or log analytics
- *aks*: subnet to host aks nodes in
- *loadbalancer*: load balancer should go here
- *back-end*: To host any storage, databases, or others
* **Network security group**: Used to control traffic flow between subnets
* **Keyvault**: Service to securely store and access secrets
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

