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
![Deploy to Azure](https://aka.ms/deploytoazurebutton)(<link to deployment script goes here>)

## Built on Zero Trust
[Find more here](/Topics/zerotrust.md)

## Built on network-level segmentation patterns
[Find more here](/Topics/networksegmentation.md)

## Assumed requirements
* All resources must be deployed in a secure fashion.
* No resource should be directly reachable from the internet, unless absolutely required.
* All resources need to be tagged.

## Architecture
### Diagram
![Basic network architecture](/Networking/images/basic.png)

### Components

### Traffic Flows