# Public IP Adress

## Parameters
* *name*: **Required** - Name of the resource Virtual Network (The name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens)
* *location*: **Required** -Azure Region where the resource will be deployed in
* *tags*: **Required** -key-value pairs as tags, to identify the resource
* *vnetAddressPrefixes*: **Required** - Array, CIDRs to be allocated to the new vnet i.e. 192.168.0.0/24
* *subnets*: **Required** - Pass an array of objects for all the required subnets
* *ddosProtectionPlanId*: **Optional** - Resource ID of the DDoS protection plan to assign the VNET to. If it\'s left blank, DDoS protection will not be configured. If it\'s provided, the VNET created by this template will be attached to the referenced DDoS protection plan. The DDoS protection plan can exist in the same or in a different subscription.

## Usage
Define the subnets as follows:

var defaultSubnets = [
  {
    name: gatewaySubnetName
    properties: {
      addressPrefix: gatewaySubnetAddressPrefix      
    }
  }
  {
    name: azureFirewallSubnetName
    properties: {
      addressPrefix: azureFirewallSubnetAddressPrefix
    }
  }
  {
    name: AzureFirewallManagementSubnetName
    properties: {
      addressPrefix: azureFirewallSubnetManagementAddressPrefix
    }
  }
]

## resource
[bicep module](/code/01%20-%20Modules/modules/vNET.bicep)