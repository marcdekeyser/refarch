@description('ACR Name')
param acrName string

@description('ACR SKU')
param acrSku string = 'Premium' //premium is needed for Private Endpoints

@description('Workspace resource ID')
param workspaceResourceId string

@description('deployment location')
param location string

@description('Subnet resource ID for PE')
param subnetresourceID string

@description('quarantie policy status')
param quarantinePolicyStatus string = 'enabled'

@description('number of days to keep soft delete')
param softDeletePolicyDays int = 7

@description('policy for soft delete')
param softDeletePolicyStatus string = 'disabled'

@description('setting for trust policy')
param trustPolicyStatus string = 'enabled' // required Premium


module registry 'br/public:avm/res/container-registry/registry:0.6.0' = {
  name: 'ACR-AKS-Deployment'
  params: {
    // Required parameters
    name: acrName
    // Non-required parameters
    acrAdminUserEnabled: false
    acrSku: acrSku
    azureADAuthenticationAsArmPolicyStatus: 'enabled'
    diagnosticSettings: [
      {
        workspaceResourceId: workspaceResourceId
      }
    ]
    exportPolicyStatus: 'enabled'
    location: location
    privateEndpoints: [
      {
        subnetResourceId: subnetresourceID
      }
    ]
    quarantinePolicyStatus: quarantinePolicyStatus
    softDeletePolicyDays: softDeletePolicyDays
    softDeletePolicyStatus: softDeletePolicyStatus
    trustPolicyStatus: trustPolicyStatus
  }
}
