targetScope = 'subscription'

metadata name = 'Using only defaults'
metadata description = 'This instance deploys the module with the minimum set of required parameters.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-customrp-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = 'westeurope' //deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'dbgmin'

@description('Optional. A token to inject into the name of each resource. This value can be automatically injected by the CI.')
param namePrefix string = 'custrp' //'#_namePrefix_#'

//
// Custom RP parameters
//
@description('Optional. The name of the function app to deploy.')
param functionAppName string = 'dep-${namePrefix}-fn-${serviceShort}'

@description('Optional. The URI of the zip file containing the function code.')
param zipFileBlobUri string = 'https://github.com/DamianFlynn/bicep-registry-modules/blob/avm-res-dashboard-grafana/avm/res/custom-providers/resource-providers/functionApp/functionApp.zip?raw=true'

@description('Optional. Actions of the resource as published in the Function Code.')
param actions array = [
  {
    name: 'ping'
    routingType: 'Proxy'
    endpoint: 'https://${functionAppName}.azurewebsites.net/api/{requestPath}'
  }
  {
    name: 'listMyCustomAction'
    routingType: 'Proxy'
    endpoint: 'https://${functionAppName}.azurewebsites.net/api/{requestPath}'
  }
  {
    name: 'listSubscriptions'
    routingType: 'Proxy'
    endpoint: 'https://${functionAppName}.azurewebsites.net/api/{requestPath}'
  }
]

@description('Optional. Resource Types of the resource as published in the function code.')
param resourceTypes array = [
  {
    name: 'ping'
    routingType: 'Proxy,Cache'
    endpoint: 'https://${functionAppName}.azurewebsites.net/api/{requestPath}'
  }
  {
    name: 'users'
    routingType: 'Proxy,Cache'
    endpoint: 'https://${functionAppName}.azurewebsites.net/api/{requestPath}'
  }
]

@description('Optional. Validations endpoints of the resource matching swagger for the code.')
param validations array = [
  {
    validationType: 'swagger'
    specification: 'https://raw.githubusercontent.com/Azure/azure-custom-providers/master/CustomRPWithSwagger/Artifacts/Swagger/pingaction.json'
  }
  {
    validationType: 'swagger'
    specification: 'https://raw.githubusercontent.com/Azure/azure-custom-providers/master/CustomRPWithSwagger/Artifacts/Swagger/userresource.json'
  }
]

// ============ //
// Dependencies //
// ============ //

// General resources
// =================
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: resourceLocation
}

module nestedDependencies 'dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-nestedDependencies'
  params: {
    location: resourceLocation
    functionAppName: functionAppName
    zipFileBlobUri: zipFileBlobUri
    tags: {
      'hidden-title': 'This is visible in the resource name'
      Environment: 'Non-Prod'
      Role: 'DeploymentValidation'
    }
    eventHubName: diagnosticDependencies.outputs.eventHubNamespaceEventHubName
    eventHubAuthorizationRuleResourceId: diagnosticDependencies.outputs.eventHubAuthorizationRuleId
    storageAccountResourceId: diagnosticDependencies.outputs.storageAccountResourceId
    workspaceResourceId: diagnosticDependencies.outputs.logAnalyticsWorkspaceResourceId
  }
}

@description('We will assign the Subscription Reader role to the managed identity so that it can enumberate subscriptions and resource graph.')
resource roleAssignmentSubscriptionReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(
    uniqueString(subscription().id, deployment().name, resourceLocation),
    '${functionAppName}-sysmi',
    'acdd72a7-3385-48ef-bd42-f606fba81ae7'
  )
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'acdd72a7-3385-48ef-bd42-f606fba81ae7'
    )
    principalId: nestedDependencies.outputs.functionAppSystemAssignedManagedIdentityId
    principalType: 'ServicePrincipal'
  }
}

// ============ //
// Diagnostics
// ============ //
module diagnosticDependencies '../../../../../../utilities/e2e-template-assets/templates/diagnostic.dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-diagnosticDependencies'
  params: {
    storageAccountName: 'dep${namePrefix}diasa${serviceShort}01'
    logAnalyticsWorkspaceName: 'dep-${namePrefix}-law-${serviceShort}'
    eventHubNamespaceEventHubName: 'dep-${namePrefix}-evh-${serviceShort}'
    eventHubNamespaceName: 'dep-${namePrefix}-evhns-${serviceShort}'
    location: resourceLocation
  }
}

// ============== //
// Test Execution //
// ============== //

@batchSize(1)
module testDeployment '../../../main.bicep' = [
  for iteration in ['init', 'idem']: {
    scope: resourceGroup
    name: '${uniqueString(deployment().name, resourceLocation)}-test-${serviceShort}-${iteration}'
    params: {
      name: '${namePrefix}${serviceShort}001'
      location: resourceLocation
      actions: actions
      resourceTypes: resourceTypes
      // validations: validations
      tags: {
        'hidden-title': 'This is visible in the resource name'
        Environment: 'Non-Prod'
        Role: 'DeploymentValidation'
      }
      lock: {
        name: 'lock'
        kind: 'None'
      }
    }
    dependsOn: [
      nestedDependencies // We require a function app to be deployed
    ]
  }
]

// Post Resource Deployment Validations

module postDeploymentVerification 'post.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-postValidations'
  params: {
    customRpName: testDeployment[0].outputs.name
    customRpId: testDeployment[0].outputs.resourceId
    location: resourceLocation
    tags: {
      'hidden-title': 'This is visible in the resource name'
      Environment: 'Non-Prod'
      Role: 'DeploymentValidation'
    }
  }
  dependsOn: [
    testDeployment
  ]
}
