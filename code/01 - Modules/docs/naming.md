# Naming
In order to standardize naming of resources and to save on string sizes the following code can be implemented.

## Parameters
@description('The name of the workload that is being deployed. Up to 10 characters long.')
@minLength(2)
@maxLength(10)
param workloadName string = 'aca'

@description('Location for the resource')
param location string = westeurope

@description('The name of the environment (e.g. "dev", "test", "prod", "uat", "dr", "qa"). Up to 8 characters long.')
@maxLength(8)
param environment string = 'test'

## Loading the namingrules
var namingRules = json(loadTextContent('modules/resources/naming-rules.jsonc'))

## naming a resource
var appgatewayName = '${namingRules.resourceTypeAbbreviations.applicationGateway}-${namingRules.regionAbbreviations[toLower(location)]}-${workloadName}-${environment}'

In this example the application gateway will be named 'agw-weu-aca-test'

## Resources
[Naming convention](/code/01%20-%20Modules/resources/naming.jsonc)

