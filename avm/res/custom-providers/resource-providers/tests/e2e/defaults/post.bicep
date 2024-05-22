metadata description = 'This resource deployment, will utilise the new Custom Resource Provider to call both its Action and Resource features. The output returned from the resource provider will then be used as the input for the test resource deployment, which in this case is a simple Application Security Group. We can see the outputs being used to provide values for tags in this example'

@description('Optional. The location to deploy resources to.')
param location string = resourceGroup().location

@description('Required. The name of the Custom Resource Provider.')
param customRpName string = 'custrpdbgmin001'

@description('Required. The Resource ID of the Custom Resource Provider.')
param customRpId string = '/subscriptions/83264035-996f-4ca6-b71e-c534333d0ccf/resourceGroups/dep-custrp-customrp-dbgmin-rg/providers/Microsoft.CustomProviders/resourceproviders/custrpdbgmin001'

@description('Optional. Tags to apply to the resources.')
param tags object = {}

// The sample application and resources in the custom provider is offering a resource called 'users'
// var customProviderResourceName = '${customRpName}/users'

// The Test Custom Resource Provider is offering a service called ListSubscriptions, which will return a list of subscriptions
// and also accepts input parameters, which are defined below
@description('Input parameters for the ListSubscriptions action of our custom resource provider.')
var crpInputParameters = {
  myProperty1: 'myPropertyValue1'
  myProperty2: {
    myProperty3: 'myPropertyValue3'
  }
}

@description('Create a new instance of the resources offered by our custom resource provider.')
resource customProviderUser1 'Microsoft.CustomProviders/resourceProviders/users@2018-09-01-preview' = {
  name: '${customRpName}/user1'
  location: location
  tags: tags
  properties: {
    FullName: 'Mystic'
    Location: 'Mayo'
  }
}

@description('This sample resource deployment will use the output of the custom resource provider to create an Application Security Group.')
module customAsg 'br/public:avm/res/network/application-security-group:0.1.3' = {
  name: '${customRpName}-asg'
  params: {
    name: '${customRpName}-asg'
    location: location
    tags: {
      // Test the output of the custom resource provider 'Resource'
      custResourceUser1: customProviderUser1.properties.randomString
      // Test the output of the custom resource provider 'Action'
      custAction: listSubscriptions(customRpId, '2018-09-01-preview', crpInputParameters).tenantId
    }
  }
}

//
// Actions Outputs
//

// Actions listed in the Custom RP must be named as follows: list<actionName>
// Following this nameing requirement, Azure ARM Functions can be called to execute the action
// The following Outputs are examples of how to call the actions

// output customActionObject object = listMyCustomAction(testDeployment[0].id, '2018-09-01-preview', functionValues)
// output customActionListSubObject object = listSubscriptions(testDeployment[0].id, '2018-09-01-preview', functionValues)
// output customActionListSubPropertyRandom string = listSubscriptions(
//   testDeployment[0].id,
//   '2018-09-01-preview',
//   functionValues
// ).subscriptions.randomString

// These outputs can also be verified using the following REST API Tests
//
// listMyCustomAction
// listURI="https://management.azure.com/subscriptions/83264035-996f-4ca6-b71e-c534333d0ccf/resourceGroups/dep-custrp-customrp-dbgmin-rg/providers/Microsoft.CustomProviders/resourceproviders/custrpdbgmin001/listMyCustomAction?api-version=2018-09-01-preview"
// az rest --method post --uri $listURI
//
// listSubscriptions Action
// listSubsURI="https://management.azure.com/subscriptions/83264035-996f-4ca6-b71e-c534333d0ccf/resourceGroups/dep-custrp-customrp-dbgmin-rg/providers/Microsoft.CustomProviders/resourceproviders/custrpdbgmin001/listSubscriptions?api-version=2018-09-01-preview"
// az rest --method post --uri $listSubsURI

//
// Resource Outputs
//

output myCustomAction object = listSubscriptions(customRpId, '2018-09-01-preview', crpInputParameters)
output myUsersObject object = customProviderUser1
output myUsersObjectName string = customProviderUser1.properties.randomString

// Test using REST API
//
// usersURI="https://management.azure.com/subscriptions/83264035-996f-4ca6-b71e-c534333d0ccf/resourceGroups/dep-custrp-customrp-dbgmin-rg/providers/Microsoft.CustomProviders/resourceproviders/custrpdbgmin001/users/user1?api-version=2018-09-01-preview"
// az rest --method post --uri $usersURI
