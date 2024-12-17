# Hub/spoke foundation
## Index
* [Description](#description)
* [Deploy to Azure](#deploy-to-azure)
* [Design](#design)
* [Components](#components)

## Description
This sample architecture aims to give you a headstart to deploying a secure and scalable environment within Azure. 

## Deploy this 
*Please note that the provided deployment is an example and should be tailored to your specific needs* 

### Prerequisites
You'll need an active Azure subscription. If you do not have one you can create a [free Azure account](https://azure.microsoft.com/free/) before beginning. You will also require a resource group to deploy the resources into

### Need to know
The network security groups have not been configured with the appropriate rules. You will need to set these up manually.

A single management and runner agent machine is deployed of the sku B2. It's recommended to change the sku and deploy multiple for scalability and redudance.

### Deploy to Azure
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmarcdekeyser%2Frefarch%2Frefs%2Fheads%2Fmain%2Fcode%2Fsol_foundation_hub_spoke%2Fmain.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fmarcdekeyser%2Frefarch%2Frefs%2Fheads%2Fmain%2Fcode%2Fsol_foundation_hub_spoke%2Fmain.json)

### Deploy using bicep
For help on deploying bicep resourced please refer to [this page](/code/DeployBicep.md)
* [Bicep Template](https://github.com/marcdekeyser/refarch/blob/man/code/sol_foundation_hub_spoke)  

## Design
![Foundational solution platform](/Solutions/Foundation_hub_spoke/images/sol_foundation_hub_spoke.png)
*Diagram: Design diagram of the foundational solution*
[visio file](/Solutions/Foundation_hub_spoke/diagrams/sol_foundation_hub_spoke.vsdx)

### Components
* **Virtual Network**: Foundational to our secure infrastructure we need a vNET to segment our networks
* **Subnet**: Multiple subnets are deployed in order to support segmenting the network. Each subnet is tied to a functionality:
- *Front-end*: This subnet would host our front-end services for the application.
- *Business logic*: Also known as 'middle-tier', this network is used to host any resources which function to coordinate the application, process commands, make logical decisions and evaluations, or perform calculations. 
- *Back-end*: Hosts resources that store information. 
- *Services*: Centralized subnet to host services such as keyvault
- *Bastion*: 
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
