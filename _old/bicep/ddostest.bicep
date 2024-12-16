@description('Name of the public IP address resource.')
param publicIpAddressName string = 'myPublicIPAddress'

@description('Azure region for the deployment, resource group and resources.')
param location string
param extendedLocation object = {}

@description('Sku for the resource.')
param sku string

@description('Domain name label for the resource.')
param domainNameLabel string = ''

@description('Domain name label scope for the resource.')
param domainNameLabelScope string = ''

@description('Routing Preference for the resource.')
param routingPreference string = ''

@description('Allocation method for the resource.')
@allowed([
  'Dynamic'
  'Static'
])
param publicIPAllocationMethod string

@description('Version for the resource.')
@allowed([
  'IPv4'
  'IPv6'
])
param publicIpAddressVersion string = 'IPv4'

@description('Idle Timeout for the resource.')
param idleTimeoutInMinutes int = 4

@description('Tier for the resource.')
@allowed([
  'Regional'
  'Global'
])
param tier string = 'Regional'

@description('Zones for the resource.')
param zones array = []

@allowed([
  'Disabled'
  'Enabled'
  'VirtualNetworkInherited'
])
param ddosProtectionMode string

@description('Optional tags for the resources.')
param tagsByResource object = {}

var dns = {
  domainNameLabel: domainNameLabel
  domainNameLabelScope: domainNameLabelScope
}
var tags = [
  {
    ipTagType: 'RoutingPreference'
    tag: routingPreference
  }
]
var ipTagsVariable = (empty(routingPreference) ? json('null') : tags)
var ddosSettings = (empty(ddosProtectionMode)
  ? json('null')
  : {
      protectionMode: ddosProtectionMode
    })
var propertiesNoDns = {
  publicIPAllocationMethod: publicIPAllocationMethod
  idleTimeoutInMinutes: idleTimeoutInMinutes
  publicIpAddressVersion: publicIpAddressVersion
  ipTags: ipTagsVariable
  ddosSettings: ddosSettings
}
var propertiesDns = {
  publicIPAllocationMethod: publicIPAllocationMethod
  idleTimeoutInMinutes: idleTimeoutInMinutes
  publicIpAddressVersion: publicIpAddressVersion
  dnsSettings: dns
  ipTags: ipTagsVariable
  ddosSettings: ddosSettings
}

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  name: publicIpAddressName
  location: location
  extendedLocation: (empty(extendedLocation) ? null : extendedLocation)
  zones: zones
  tags: tagsByResource
  sku: {
    name: sku
    tier: tier
  }
  properties: (empty(domainNameLabel) ? propertiesNoDns : propertiesDns)
}
