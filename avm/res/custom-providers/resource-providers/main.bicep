metadata name = 'Azure Custom Resource Provider'
metadata description = 'This module deploys an Azure Custom Resource Provider.'
metadata owner = 'InnofactorOrg/module-maintainers'

@description('Required. Name of your Azure Custom Provider.')
@minLength(5)
@maxLength(50)
param name string

@description('Optional. Location for all Resources.')
param location string = resourceGroup().location

@description('Optional. Tags of the resource.')
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

// RP Endpoint 'https://jarvis-2024-05-05.azurewebsites.net/api/{requestPath}'
// new App  'https://jarvis-2024-05-05.azurewebsites.net/api/subscriptions/{subscriptionId}/resourcegroups/{resourceGroupName}/providers/Microsoft.CustomProviders/resourceproviders/{minirpname}/{action}?'
// work app    'https://jarvis20240507.azurewebsites.net/api/subscriptions/{subscriptionId}/resourcegroups/{resourceGroupName}/providers/Microsoft.CustomProviders/resourceproviders/{minirpname}/{action}?'

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

// module getMyData 'getMyData.bicep' = {
//   name: 'getMyData'
//   params: {
//     customRpId: customProvider.id
//     functionValues: {
//       myProperty1: 'myPropertyValue1'
//       myProperty2: {
//         myProperty3: 'myPropertyValue3'
//       }
//     }
//   }
// }

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
