targetScope = 'subscription'

metadata name = 'Azure Container Registry'
metadata description = 'This Instance deploys an Azure Container Registry.'
metadata owner = 'Azure/module-maintainers'

@description('Required. Name of the resource to create.')
param name string

@description('Optional. Location for all Resources.')
param location string = deployment().location

@description('Optional. The environment to deploy the resources to.')
param environment string = 'Prod'

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

@description('Optional. Tags to be added to the resources.')
param tags object = {
  'hidden-title': 'Innofactor Bicep Container Registry'
  Environment: 'Prod'
  Role: 'Registry'
  Owner: 'Azure Practice'
  Repository: 'innofactororg/azure-solutions'
  Contact: 'damian.flynn@innofactor.com'
}

//
// Add your parameters here
//

// ============== //
// Resources      //
// ============== //

resource avmTelemetry 'Microsoft.Resources/deployments@2023-07-01' = if (enableTelemetry) {
  name: take(
    '46d3xbcp.ptn.containerregistry-landingzone.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, location), 0, 4)}',
    64
  )
  location: location
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
      outputs: {
        telemetry: {
          type: 'String'
          value: 'For more information, see https://aka.ms/avm/TelemetryInfo'
        }
      }
    }
  }
}

//
// Add your resources here
//

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${toLower(take(environment,1))}-${name}'
  location: location
  tags: tags
}

// ACR Pull Role - 7f951dda-4ed3-4680-a7ca-43fe172d538d
// ACR Push Role - 8311e382-0749-4cb8-b61a-304f252e45ec

module acr 'br/public:avm/res/container-registry/registry:0.1.1' = {
  scope: resourceGroup
  name: '${toLower(uniqueString(deployment().name, location))}-landindzone'
  params: {
    name: take(replace(replace(replace('${resourceGroup.name}', '-', ''), '.', ''), '_', ''), 50)
    location: location
    exportPolicyStatus: 'enabled'
    acrAdminUserEnabled: true
    azureADAuthenticationAsArmPolicyStatus: 'enabled'
    acrSku: 'Standard'
    lock: {
      kind: 'CanNotDelete'
      name: '${resourceGroup.name}-acr-Lock'
    }
    managedIdentities: {
      systemAssigned: true
    }
    roleAssignments: [
      // {
      //   // Contributor
      //   roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
      //   principalId: '34d9c953-c93b-4a85-b103-3bdf1324f354' // iacinnofactor
      //   principalType: 'ServicePrincipal'
      // }
    ]

    tags: tags
  }
}

// ============ //
// Outputs      //
// ============ //

// Add your outputs here

// @description('The resource ID of the resource.')
// output resourceId string = <Resource>.id

// @description('The name of the resource.')
// output name string = <Resource>.name

// @description('The location the resource was deployed into.')
// output location string = <Resource>.location

// ================ //
// Definitions      //
// ================ //
//
// Add your User-defined-types here, if any
//
