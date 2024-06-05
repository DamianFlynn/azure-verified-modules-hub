targetScope = 'subscription'

metadata name = 'Spoke Landing Zone with Virtual Machine WAF Aligned'
metadata description = 'This module deploys an Azure Continer Registry using minimal parameters.'
metadata owner = 'Azure/avm-ptn-lz-spoke-module-owners-bicep'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
// e.g., for a module 'network/private-endpoint' you could use 'dep-dev-network.privateendpoints-${serviceShort}-rg'
param resourceGroupName string = 'dep-${namePrefix}-lz-spoke-${serviceShort}'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
// e.g., for a module 'network/private-endpoint' you could use 'npe' as a prefix and then 'waf' as a suffix for the waf-aligned test
param serviceShort string = 'lzmin'

@description('Optional. A token to inject into the name of each resource. This value can be automatically injected by the CI.')
param namePrefix string = '#_namePrefix_#'

// ============ //
// Dependencies //
// ============ //

var locationAbbreviations = {
  'westeurope': 'we'
  'westus': 'wu'
  'eastus': 'eu'
  // Add more locations as needed
}

var currentLocationAbbreviation = locationAbbreviations[resourceLocation]
var addressPrefix = '10.0.0.0/24'

// General resources
// =================
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  // name: '${resourceGroupName}-diag'
  name: 't-${currentLocationAbbreviation}1${serviceShort}-diag-${namePrefix}'
  location: resourceLocation
}

// Diagnostics
// ===========

module diagnosticDependencies '../../../../../../utilities/e2e-template-assets/templates/diagnostic.dependencies.bicep' = {
  scope: resourceGroup
  name: '${serviceShort}-dep-test-diag-${uniqueString(deployment().name, resourceLocation)}'
  params: {
    storageAccountName: take(
      replace(replace('t-${currentLocationAbbreviation}1${serviceShort}-diag-${namePrefix}', '-', ''), '_', ''),
      24
    )
    logAnalyticsWorkspaceName: 't-${currentLocationAbbreviation}1${serviceShort}-diag-${namePrefix}-law'
    eventHubNamespaceEventHubName: 't-${currentLocationAbbreviation}1${serviceShort}-diag-${namePrefix}-evh'
    eventHubNamespaceName: 't-${currentLocationAbbreviation}1${serviceShort}-diag-${namePrefix}-evhns'
    location: resourceLocation
  }
}

// ============== //
// Test Execution //
// ============== //

@batchSize(1)
module testDeployment '../../../main.bicep' = [
  for iteration in ['init', 'idem']: {
    name: '${serviceShort}-${iteration}-test-${uniqueString(deployment().name, resourceLocation)}'
    params: {
      // You parameters go here
      name: 't-${currentLocationAbbreviation}1${serviceShort}-${namePrefix}'
      location: resourceLocation
      // enableBCDR: false
      addressPrefix: addressPrefix
      frontendSecurityRules: [
        {
          name: 'AllowRdoFromFirewallToFrontendsubnet'
          properties: {
            description: 'Allow RDP Connections from the Azure Firewall'
            protocol: 'Udp'
            sourcePortRange: '*'
            destinationPortRange: '3389'
            sourceAddressPrefix: '10.1.1.4'
            destinationAddressPrefix: cidrSubnet(addressPrefix, 25, 0)
            access: 'Allow'
            priority: 1100
            direction: 'Inbound'
          }
        }
      ]
      eventHubName: diagnosticDependencies.outputs.eventHubNamespaceEventHubName
      eventHubAuthorizationRuleResourceId: diagnosticDependencies.outputs.eventHubAuthorizationRuleId
      storageAccountResourceId: diagnosticDependencies.outputs.storageAccountResourceId
      workspaceResourceId: diagnosticDependencies.outputs.logAnalyticsWorkspaceResourceId
      tags: {
        Environment: 'Non-Prod'
        Role: 'DeploymentValidation'
      }
    }
  }
]
