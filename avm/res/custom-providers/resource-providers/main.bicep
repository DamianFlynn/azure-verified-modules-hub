metadata name = 'Azure Custom Resource Provider'
metadata description = 'This module deploys an Azure Custom Resource Provider.'
metadata owner = 'InnofactorOrg/module-maintainers'

@description('Required. Name of your Azure Custom Provider.')
@minLength(5)
@maxLength(50)
param name string

@description('Optional. Location for all Resources.')
param location string = resourceGroup().location

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

@description('Optional. The lock settings of the service.')
param lock lockType

@description('Optional. Tags of the storage account resource.')
param tags object?

//
// Add your parameters here
//

@description('Optional. Actions of the resource.')
param actions array = []

@description('Optional. Resource Types of the resource.')
param resourceTypes array = []

@description('Optional. Validations endpoints of the resource.')
param validations array = []

// ============== //
// Resources      //
// ============== //

resource avmTelemetry 'Microsoft.Resources/deployments@2023-07-01' = if (enableTelemetry) {
  name: '46d3xbcp.ptn.customproviders-resourceproviders.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, location), 0, 4)}'
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

resource customProvider_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'
  }
  scope: customProvider
}

resource customProvider 'Microsoft.CustomProviders/resourceProviders@2018-09-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    actions: length(actions) == 0 ? null : actions
    resourceTypes: length(resourceTypes) == 0 ? null : resourceTypes
    validations: length(validations) == 0 ? null : validations
  }
}

// ============ //
// Outputs      //
// ============ //

// Add your outputs here

@description('The Name of the Azure Custom Provider.')
output name string = customProvider.name

@description('The name of the Resource Group.')
output resourceGroupName string = resourceGroup().name

@description('The resource ID of the Azure Custom Provider.')
output resourceId string = customProvider.id

@description('The location the resource was deployed into.')
output location string = customProvider.location

// ================ //
// Definitions      //
// ================ //
//
// Add your User-defined-types here, if any
//

type lockType = {
  @description('Optional. Specify the name of lock.')
  name: string?

  @description('Optional. Specify the type of lock.')
  kind: ('CanNotDelete' | 'ReadOnly' | 'None')?
}?
