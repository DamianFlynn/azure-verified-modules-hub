targetScope = 'subscription'
metadata name = 'Security Insights - Alert Rules Default Configuration'
metadata description = 'This sample Bicep file demonstrates how to utilize the alertRules module to deploy predefined alert rules to an Azure Sentinel workspace. The Bicep file dynamically loads alert rules from source JSON or YAML files using the loadJsonContent or loadYamlContent functions, respectively. Additionally, it allows for the inclusion of customer-specific rules or overrides via a secondary array. Both arrays are combined using the native Bicep union function before being passed to the module for application.'
metadata owner = '@InnofactorOrg/azure-solutions-#_namePrefix_#-ptn-securityinsights-alertrules-module-owners'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
// e.g., for a module 'network/private-endpoint' you could use 'dep-dev-network.privateendpoints-${serviceShort}-rg'
param resourceGroupName string = 'dep-${namePrefix}-securityinsights-alertrules-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
// e.g., for a module 'network/private-endpoint' you could use 'npe' as a prefix and then 'waf' as a suffix for the waf-aligned test
param serviceShort string = 'csocmin'

@description('Optional. A token to inject into the name of each resource. This value can be automatically injected by the CI.')
param namePrefix string = '#_namePrefix_#'

@description('Optional. An array of rules to deploy for Azure Sentinel.')
param overideRules array = [
  {
    name: '223db5c1-1bf8-47d8-8806-bed401b356a4'
    type: 'Microsoft.SecurityInsights/AlertRuleTemplates'
    kind: 'Scheduled'
    properties: {
      queryFrequency: 'P1D'
      queryPeriod: 'P7D'
      triggerOperator: 'GreaterThan'
      triggerThreshold: 0
      severity: 'Low'
      query: 'let timeRange = 1d;\nlet lookBack = 7d;\nlet threshold_Failed = 5;\nlet threshold_FailedwithSingleIP = 20;\nlet threshold_IPAddressCount = 2;\nlet isGUID = "[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}";\nlet aadFunc = (tableName:string){\nlet azPortalSignins = materialize(table(tableName)\n| where TimeGenerated >= ago(lookBack)\n// Azure Portal only\n| where AppDisplayName =~ "Azure Portal")\n;\nlet successPortalSignins = azPortalSignins\n| where TimeGenerated >= ago(timeRange)\n// Azure Portal only and exclude non-failure Result Types\n| where ResultType in ("0", "50125", "50140")\n// Tagging identities not resolved to friendly names\n//| extend Unresolved = iff(Identity matches regex isGUID, true, false)\n| distinct TimeGenerated, UserPrincipalName\n;\nlet failPortalSignins = azPortalSignins\n| where TimeGenerated >= ago(timeRange)\n// Azure Portal only and exclude non-failure Result Types\n| where ResultType !in ("0", "50125", "50140", "70044", "70043")\n// Tagging identities not resolved to friendly names\n| extend Unresolved = iff(Identity matches regex isGUID, true, false)\n;\n// Verify there is no success for the same connection attempt after the fail\nlet failnoSuccess = failPortalSignins | join kind= leftouter (\n   successPortalSignins\n) on UserPrincipalName\n| where TimeGenerated > TimeGenerated1 or isempty(TimeGenerated1)\n| project-away TimeGenerated1, UserPrincipalName1\n;\n// Lookup up resolved identities from last 7 days\nlet identityLookup = azPortalSignins\n| where TimeGenerated >= ago(lookBack)\n| where not(Identity matches regex isGUID)\n| summarize by UserId, lu_UserDisplayName = UserDisplayName, lu_UserPrincipalName = UserPrincipalName;\n// Join resolved names to unresolved list from portal signins\nlet unresolvedNames = failnoSuccess | where Unresolved == true | join kind= inner (\n   identityLookup\n) on UserId\n| extend UserDisplayName = lu_UserDisplayName, UserPrincipalName = lu_UserPrincipalName\n| project-away lu_UserDisplayName, lu_UserPrincipalName;\n// Join Signins that had resolved names with list of unresolved that now have a resolved name\nlet u_azPortalSignins = failnoSuccess | where Unresolved == false | union unresolvedNames;\nu_azPortalSignins\n| extend DeviceDetail = todynamic(DeviceDetail), Status = todynamic(DeviceDetail), LocationDetails = todynamic(LocationDetails)\n| extend Status = strcat(ResultType, ": ", ResultDescription), OS = tostring(DeviceDetail.operatingSystem), Browser = tostring(DeviceDetail.browser)\n| extend State = tostring(LocationDetails.state), City = tostring(LocationDetails.city), Region = tostring(LocationDetails.countryOrRegion)\n| extend FullLocation = strcat(Region,\'|\', State, \'|\', City)  \n| summarize TimeGenerated = make_list(TimeGenerated,100), Status = make_list(Status,100), IPAddresses = make_list(IPAddress,100), IPAddressCount = dcount(IPAddress), FailedLogonCount = count()\nby UserPrincipalName, UserId, UserDisplayName, AppDisplayName, Browser, OS, FullLocation, Type\n| mvexpand TimeGenerated, IPAddresses, Status\n| extend TimeGenerated = todatetime(tostring(TimeGenerated)), IPAddress = tostring(IPAddresses), Status = tostring(Status)\n| project-away IPAddresses\n| summarize StartTime = min(TimeGenerated), EndTime = max(TimeGenerated) by UserPrincipalName, UserId, UserDisplayName, Status, FailedLogonCount, IPAddress, IPAddressCount, AppDisplayName, Browser, OS, FullLocation, Type\n| where (IPAddressCount >= threshold_IPAddressCount and FailedLogonCount >= threshold_Failed) or FailedLogonCount >= threshold_FailedwithSingleIP\n| extend timestamp = StartTime, Name = tostring(split(UserPrincipalName,\'@\',0)[0]), UPNSuffix = tostring(split(UserPrincipalName,\'@\',1)[0])\n};\nlet aadSignin = aadFunc("SigninLogs");\nlet aadNonInt = aadFunc("AADNonInteractiveUserSignInLogs");\nunion isfuzzy=true aadSignin, aadNonInt'
      entityMappings: [
        {
          entityType: 'Account'
          fieldMappings: [
            {
              identifier: 'Name'
              columnName: 'Name'
            }
            {
              identifier: 'UPNSuffix'
              columnName: 'UPNSuffix'
            }
          ]
        }
        {
          entityType: 'IP'
          fieldMappings: [
            {
              identifier: 'Address'
              columnName: 'IPAddress'
            }
          ]
        }
      ]
      version: '1.0.4'
      tactics: [
        'CredentialAccess'
      ]
      techniques: [
        'T1110'
      ]
      displayName: 'Failed login attempts to Azure Portal'
      description: 'Identifies failed login attempts in the Azure Active Directory SigninLogs to the Azure Portal.  Many failed logon\nattempts or some failed logon attempts from multiple IPs could indicate a potential brute force attack.\nThe following are excluded due to success and non-failure results:\nReferences: https://docs.microsoft.com/azure/active-directory/reports-monitoring/reference-sign-ins-error-codes\n0 - successful logon\n50125 - Sign-in was interrupted due to a password reset or password registration entry.\n50140 - This error occurred due to \'Keep me signed in\' interrupt when the user was signing-in.'
      lastUpdatedDateUTC: '2023-10-09T00:00:00Z'
      createdDateUTC: '2019-02-11T00:00:00Z'
      status: 'Available'
      requiredDataConnectors: [
        {
          connectorId: 'AzureActiveDirectory'
          dataTypes: [
            'SigninLogs'
          ]
        }
        {
          connectorId: 'AzureActiveDirectory'
          dataTypes: [
            'AADNonInteractiveUserSignInLogs'
          ]
        }
      ]
      alertRulesCreatedByTemplateCount: 1
      suppressionDuration: 'PT5H'
      suppressionEnabled: false
      enabled: true
      alertRuleTemplateName: '223db5c1-1bf8-47d8-8806-bed401b356a4'
      templateVersion: '1.0.4'
    }
  }
]

@description('Optional. An array of rules to deploy for Azure Sentinel.')
param alertRules array = [
  // loadJsonContent('../../../configuration/rules/scheduled/Account added and removed from privileged groups.json')
  // loadJsonContent('../../../configuration/rules/scheduled/User Added to Admin Role.json')
  // loadJsonContent('../../../configuration/rules/scheduled/User impersonation by Identity Protection alerts.json')
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

// Dependencies for the module
// ===========================

// Deploy some diagnostics resources for the module use in the test
module diagnostics '../../../../../../utilities/e2e-template-assets/templates/diagnostic.dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-diagnosticDependencies'
  params: {
    storageAccountName: 'dep${namePrefix}azsa${serviceShort}01'
    logAnalyticsWorkspaceName: 'dep-${namePrefix}-law-${serviceShort}'
    eventHubNamespaceEventHubName: 'dep-${namePrefix}-evh-${serviceShort}'
    eventHubNamespaceName: 'dep-${namePrefix}-evhns-${serviceShort}'
    location: resourceLocation
  }
}

// ============== //
// Test Execution //
// ============== //

// Load and parse the rule set we are to work with
var combinedRules = union(alertRules, overideRules)

@batchSize(1)
module testDeployment '../../../main.bicep' = [
  for iteration in ['init', 'idem']: {
    scope: resourceGroup
    name: '${uniqueString(deployment().name, resourceLocation)}-test-${serviceShort}-${iteration}'
    params: {
      // You parameters go here
      name: '${namePrefix}${serviceShort}001'
      location: resourceLocation
      sentinelWorkspaceId: diagnostics.outputs.logAnalyticsWorkspaceResourceId
      rules: combinedRules
      lock: {
        kind: 'None'
      }
      tags: {
        'hidden-title': 'This is visible in the resource name'
        Environment: 'Non-Prod'
        Role: 'DeploymentValidation'
      }
    }
    dependsOn: [
      diagnostics
    ]
  }
]
