// load as text (and not as Json) to replace <location> placeholder in the nsg rules
var nsgCaeRules = json( replace( loadTextContent('./nsgContainerAppsEnvironment.jsonc') , '<location>', locationVar) )
var nsgAppGwRules = loadJsonContent('./nsgAppGwRules.jsonc', 'securityRules')