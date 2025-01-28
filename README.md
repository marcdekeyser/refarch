# Microsoft Azure quickstart Architectures
## Index
* [Modules](#modules)
* [Concepts](#concepts)
* [Quickstarts](#quick-starts)
    * [Networking](#networking)
* [Solutions](#solutions)

## Overview
The aim of this repo is to provide you with a number of quickstart architectures, starting from the very basic to get started building your solution in Microsoft Azure. Each of theses architectures are built on (although simplified): 

- Zero Trust principles
- Well Architected Framework
- Cloud Adoption Framework

Each includes both bicep 'ready-to-deploy' code, as well as a 'Deploy to Azure' button so you can deploy straight from the reference architecure of your choosing!

## miscellaneous
* [Renaming Azure domain](/misc/rename_Azure_domain.md)
* [Renaming SharePoint and Onedrive domain](/misc/rename_SPO_tenant.md)

## Modules
* [index](/code/01%20-%20Modules/docs/readme.md)
* [Naming](/code/01%20-%20Modules/docs/naming.md)

## Concepts
* [Zero Trust](/concepts/zerotrust.md)
* [Network segmentation](/concepts/networksegmentation.md)

## Quick starts
### Components
* [Hub platform](/components/hubplatform.md) - Basic foundational platform that can be used to peer spoke networks to. Ideal for centralization of certain resources.
* [AKS platform](/components/diagrams/comp_aks.vsdx) - AKS deployment with WAF aligned paramets.

#### Networking
* [Single virtual network - Pattern 1](/concepts/networksegmentation.md)
* [Multiple virtual networks - Pattern 2](/concepts/networksegmentation.md)
* [Meshed network - Pattern 3](/concepts/networksegmentation.md)
* [Hub and Spoke - Pattern 4](/concepts/networksegmentation.md)

### Solutions
#### Foundation
* [All-in-one foundation platform](/Solutions/Foundation/foundation.md) - Simple all in one platform resources can be deployed in.
* [Hub and spoke foundation](/Solutions/Foundation_hub_spoke/foundation.md) - Hub/Spoke network with common resources in the hub network. The spoke network can be used for deploying application resources.
* [Azure Kubernetes Services - Hub/Spoke model](/Solutions/aks_hub_spoke/aks_hub_spoke.md) - Hub/Spoke network AKS deployment.
* [Azure Container Apps - Hub/Spoke model](/Solutions/aca_hub_spoke/aca_hub_spoke.md) - Hub/Spoke Azure Container apps deployment.
* [Azure Container Apps with Azure OpenAI - Hub/Spoke model](/Solutions/aca_hub_spoke_OpenAI/aca_hub_spoke_openai.md) - Hub/Spoke Azure Container apps deployment with OpenAI/GPT3.5 Turbo.
* [Azure Container Apps with Azure redis cache - Hub/Spoke model](/Solutions/aca_hub_spoke_OpenAI/aca_hub_spoke_redis.md) - Hub/Spoke Azure Container apps deployment with Azure Redis cache.
* [Azure Container Apps with Azure OpenAI & Redis cache - Hub/Spoke model](/Solutions/aca_hub_spoke_OpenAI/aca_hub_spoke_openai.md) - Hub/Spoke Azure Container apps deployment with OpenAI/GPT3.5 Turbo and Azure redis cache.