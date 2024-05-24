metadata name = 'Security Insights - Alert Rules Module'
metadata description = 'This Bicep module streamlines the configuration of Azure Sentinel by encompassing critical functionalities such as resource locking, Sentinel solution deployment, and alert rule setup within a Sentinel workspace. Key components include sentinel_lock for resource protection, sentinelWorkspace for existing workspace referencing, sentinel for solution deployment, and scheduledAlertRules for dynamic alert rule deployment. Tailored for flexibility, it adapts to input parameters to conditionally deploy resources, ensuring efficient setup and management of Azure Sentinel environments.'
metadata owner = '@InnofactorOrg/azure-solutions-avm-ptn-securityinsights-alertrules-module-owners'

@description('Required. Name of the resource to create.')
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

@description('Required. The workspace ID of the Sentinel workspace we will be working with.')
param sentinelWorkspaceId string

@description('Optional. An array of alert rules to create.')
param rules array = []

// ============== //
// Resources      //
// ============== //

resource avmTelemetry 'Microsoft.Resources/deployments@2023-07-01' = if (enableTelemetry) {
  name: '46d3xbcp.res.securityinsights-alertrules.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, location), 0, 4)}'
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

resource sentinel_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'
  }
  scope: sentinelWorkspace
}

// Get the existing Sentinel workspace

resource sentinelWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = if (!empty(sentinelWorkspaceId) && !empty(rules)) {
  name: last(split((!empty(sentinelWorkspaceId) ? sentinelWorkspaceId : 'law'), '/'))!
}

// Ensure we have the sentinel solution

resource sentinel 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (!empty(sentinelWorkspaceId) && !empty(rules)) {
  name: 'SecurityInsights(${sentinelWorkspace.name})'
  location: location
  tags: tags
  properties: {
    workspaceResourceId: sentinelWorkspace.id
  }
  plan: {
    name: 'SecurityInsights(${sentinelWorkspace.name})'
    product: 'OMSGallery/SecurityInsights'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

// Deploy rules

resource scheduledAlertRules 'Microsoft.SecurityInsights/alertRules@2023-02-01-preview' = [
  for (rule, index) in rules: {
    name: rule.name
    scope: sentinelWorkspace
    kind: rule.kind
    properties: rule.properties
    tags: tags
    dependsOn: [sentinel]
  }
]

// ============ //
// Outputs      //
// ============ //

// Add your outputs here

@description('The resource ID of the resource.')
output resourceId string = sentinelWorkspace.id

@description('The resource group of the resource.')
output resourceGroupName string = resourceGroup().name

@description('The name of the resource.')
output name string = sentinelWorkspace.name

@description('The location the resource was deployed into.')
output location string = sentinelWorkspace.location

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
