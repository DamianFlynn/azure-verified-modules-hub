targetScope = 'subscription'

metadata name = 'Spoke Landing Zone with Virtual Machine'
metadata description = 'This Instance deploys a Spoke Landing Zone with Virtual Machine'
metadata owner = 'Azure/avm-ptn-lz-spoke-module-owners-bicep'

@description('Required. Name of the resource to create.')
param name string

@description('Required. Location for all Resources.')
param location string

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

//
// Add your parameters here
//
@description('Optional. The address prefix for the virtual network.')
param addressPrefix string = '10.0.0.0/24'

@description('Optional. The event hub namespace name.')
param eventHubName string = ''

@description('Optional. The event hub authorization rule resource ID.')
param eventHubAuthorizationRuleResourceId string = ''

@description('Optional. The storage account resource ID.')
param storageAccountResourceId string = ''

@description('Optional. The log analytics workspace resource ID.')
param workspaceResourceId string = ''

// ============== //
// Resources      //
// ============== //

resource avmTelemetry 'Microsoft.Resources/deployments@2023-07-01' = if (enableTelemetry) {
  name: take(
    '46d3xbcp.ptn.lz-spoke.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, location), 0, 4)}',
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

// Security Center
// ===============

module securityCenter 'br/public:avm/ptn/security/security-center:0.1.0' = {
  name: '${uniqueString(deployment().name, location)}-vnet-${name}'
  params: {
    scope: '/subscriptions/${subscription().subscriptionId}'
    workspaceResourceId: workspaceResourceId
    location: location
    securityContactProperties: {
      alertNotifications: 'Off'
      alertsToAdmins: 'Off'
      email: 'damian.flynn@innofactor.com'
      phone: '+12345678'
    }
  }
}

// Network resources
// =================

resource networkResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${name}-net'
  location: location
}

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.1.6' = {
  scope: networkResourceGroup
  name: '${uniqueString(deployment().name, location)}-vnet-${name}'
  params: {
    addressPrefixes: [
      addressPrefix
    ]
    name: '${name}-vnet'
    tags: {
      network: addressPrefix
    }
    subnets: [
      {
        addressPrefix: cidrSubnet(addressPrefix, 25, 0)
        name: 'FrontendSubnet'
      }
    ]
  }
}

// Routes are defined in ./frontendSubnet/frontendSubnetUdrs.bicep
module frontendRouteTable_Resource 'br/public:avm/res/network/route-table:0.2.2' = {
  scope: networkResourceGroup
  name: '${name}-RouteTableName}_Resource'
  params: {
    enableTelemetry: false
    name: '${name}-FrontendSubnet-RT'
    routes: []
  }
}

module applicationSecurityGroup 'br/public:avm/res/network/application-security-group:0.1.3' = {
  scope: networkResourceGroup
  name: '${uniqueString(deployment().name, location)}-asg-${name}'
  params: {
    name: '${name}-asg'
    tags: {
      network: addressPrefix
    }
  }
}

// TODO: Network Watcher module
// https://github.com/Azure/bicep-registry-modules/blob/main/avm/res/network/network-watcher/tests/e2e/waf-aligned/main.test.bicep

// General resources
// =================

resource workloadResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: name
  location: location
}

module managedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.2.1' = {
  scope: workloadResourceGroup
  name: '${uniqueString(deployment().name, location)}-mi-${name}'
  params: {
    name: '${name}-mi'
    tags: {
      'hidden-title': 'Managed Identity'
      Environment: 'Non-Prod'
      Role: 'Workload Managed Identity'
    }
    lock: {
      kind: 'CanNotDelete'
      name: 'myCustomLockName'
    }
  }
}

module loadBalancer 'br/public:avm/res/network/load-balancer:0.1.4' = {
  scope: workloadResourceGroup
  name: '${uniqueString(deployment().name, location)}-lb-${name}'
  params: {
    name: '${name}-lb'
    tags: {
      'hidden-title': 'This is visible in the resource name'
      Environment: 'Non-Prod'
      Role: 'Spoke Workload Load Balancer'
    }
    skuName: 'Standard'
    frontendIPConfigurations: [
      {
        name: '${name}-lb-privateIP'
        subnetId: virtualNetwork.outputs.subnetResourceIds[0]
      }
    ]

    backendAddressPools: [
      {
        name: 'servers'
      }
    ]
    inboundNatRules: [
      {
        backendPort: 443
        enableFloatingIP: false
        enableTcpReset: false
        frontendIPConfigurationName: '${name}-lb-privateIP'
        frontendPort: 443
        idleTimeoutInMinutes: 4
        name: 'HTTPS Inbound NAT Rule'
        protocol: 'Tcp'
      }
      {
        backendPort: 3389
        frontendIPConfigurationName: '${name}-lb-privateIP'
        frontendPort: 3389
        name: 'RDP Inbound NAT Rule'
      }
      {
        backendPort: 22
        frontendIPConfigurationName: '${name}-lb-privateIP'
        frontendPort: 22
        name: 'SSH Inbound NAT Rule'
        protocol: 'Udp'
      }
    ]
    loadBalancingRules: [
      {
        backendAddressPoolName: 'servers'
        backendPort: 0
        disableOutboundSnat: true
        enableFloatingIP: true
        enableTcpReset: false
        frontendIPConfigurationName: '${name}-lb-privateIP'
        frontendPort: 0
        idleTimeoutInMinutes: 4
        loadDistribution: 'Default'
        name: '${name}-frontend-ip-lb-rule'
        probeName: '${name}-lb-probe1'
        protocol: 'All'
      }
    ]
    probes: [
      {
        intervalInSeconds: 5
        name: '${name}-lb-probe1'
        numberOfProbes: 2
        port: '62000'
        protocol: 'Tcp'
      }
    ]
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Owner'
        principalId: managedIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
      }
      {
        roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
        principalId: managedIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
      }
      {
        roleDefinitionIdOrName: subscriptionResourceId(
          'Microsoft.Authorization/roleDefinitions',
          'acdd72a7-3385-48ef-bd42-f606fba81ae7'
        )
        principalId: managedIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
      }
    ]
    lock: {
      kind: 'CanNotDelete'
      name: 'myCustomLockName'
    }
    diagnosticSettings: [
      {
        name: 'customSetting'
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        eventHubName: eventHubName
        eventHubAuthorizationRuleResourceId: eventHubAuthorizationRuleResourceId
        storageAccountResourceId: storageAccountResourceId
        workspaceResourceId: workspaceResourceId
      }
    ]
  }
}

module recoveryServices 'br/public:avm/res/recovery-services/vault:0.2.1' = {
  scope: workloadResourceGroup
  name: '${uniqueString(deployment().name, location)}-rs-${name}'
  params: {
    name: '${name}-rs'
    replicationAlertSettings: {
      customEmailAddresses: [
        'damian.flynn@innofactor.com'
      ]
      locale: 'en-IE'
      sendToOwners: 'Send'
    }
    securitySettings: {
      immutabilitySettings: {
        state: 'Unlocked'
      }
    }
    backupPolicies: [
      {
        name: 'vmBackupPolicy'
        properties: {
          backupManagementType: 'AzureIaasVM'
          instantRPDetails: {}
          instantRpRetentionRangeInDays: 2
          protectedItemsCount: 0
          retentionPolicy: {
            dailySchedule: {
              retentionDuration: {
                count: 180
                durationType: 'Days'
              }
              retentionTimes: [
                '2019-11-07T07:00:00Z'
              ]
            }
            monthlySchedule: {
              retentionDuration: {
                count: 60
                durationType: 'Months'
              }
              retentionScheduleFormatType: 'Weekly'
              retentionScheduleWeekly: {
                daysOfTheWeek: [
                  'Sunday'
                ]
                weeksOfTheMonth: [
                  'First'
                ]
              }
              retentionTimes: [
                '2019-11-07T07:00:00Z'
              ]
            }
            retentionPolicyType: 'LongTermRetentionPolicy'
            weeklySchedule: {
              daysOfTheWeek: [
                'Sunday'
              ]
              retentionDuration: {
                count: 12
                durationType: 'Weeks'
              }
              retentionTimes: [
                '2019-11-07T07:00:00Z'
              ]
            }
            yearlySchedule: {
              monthsOfYear: [
                'January'
              ]
              retentionDuration: {
                count: 10
                durationType: 'Years'
              }
              retentionScheduleFormatType: 'Weekly'
              retentionScheduleWeekly: {
                daysOfTheWeek: [
                  'Sunday'
                ]
                weeksOfTheMonth: [
                  'First'
                ]
              }
              retentionTimes: [
                '2019-11-07T07:00:00Z'
              ]
            }
          }
          schedulePolicy: {
            schedulePolicyType: 'SimpleSchedulePolicy'
            scheduleRunFrequency: 'Daily'
            scheduleRunTimes: [
              '2019-11-07T07:00:00Z'
            ]
            scheduleWeeklyFrequency: 0
          }
          timeZone: 'UTC'
        }
      }
    ]
    backupStorageConfig: {
      crossRegionRestoreFlag: true
      storageModelType: 'GeoRedundant'
    }
    diagnosticSettings: [
      {
        name: 'customSetting'
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        eventHubName: eventHubName
        eventHubAuthorizationRuleResourceId: eventHubAuthorizationRuleResourceId
        storageAccountResourceId: storageAccountResourceId
        workspaceResourceId: workspaceResourceId
      }
    ]
    lock: {
      kind: 'CanNotDelete'
      name: 'myCustomLockName'
    }
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: [
        managedIdentity.outputs.resourceId
      ]
    }
    monitoringSettings: {
      azureMonitorAlertSettings: {
        alertsForAllJobFailures: 'Enabled'
      }
      classicAlertSettings: {
        alertsForCriticalOperations: 'Enabled'
      }
    }
    backupConfig: {
      enhancedSecurityState: 'Disabled'
      softDeleteFeatureState: 'Disabled'
    }
    replicationFabrics: [
      {
        location: 'NorthEurope'
        replicationContainers: [
          {
            name: 'ne-container1'
            replicationContainerMappings: [
              {
                policyName: 'Default_values'
                targetContainerName: 'pluto'
                targetProtectionContainerId: '${workloadResourceGroup.id}/providers/Microsoft.RecoveryServices/vaults/${name}-rs/replicationFabrics/NorthEurope/replicationProtectionContainers/ne-container2'
              }
            ]
          }
          {
            name: 'ne-container2'
            replicationContainerMappings: [
              {
                policyName: 'Default_values'
                targetContainerFabricName: 'WE-2'
                targetContainerName: 'we-container1'
              }
            ]
          }
        ]
      }
      {
        location: 'WestEurope'
        name: 'WE-2'
        replicationContainers: [
          {
            name: 'we-container1'
            replicationContainerMappings: [
              {
                policyName: 'Default_values'
                targetContainerFabricName: 'NorthEurope'
                targetContainerName: 'ne-container2'
              }
            ]
          }
        ]
      }
    ]
    replicationPolicies: [
      {
        name: 'Default_values'
      }
      {
        appConsistentFrequencyInMinutes: 240
        crashConsistentFrequencyInMinutes: 7
        multiVmSyncStatus: 'Disable'
        name: 'Custom_values'
        recoveryPointHistory: 2880
      }
    ]
    tags: {
      'hidden-title': 'This is visible in the resource name'
      Environment: 'Non-Prod'
      Role: 'DeploymentValidation'
    }
  }
}

module virtualMachine 'br/public:avm/res/compute/virtual-machine:0.4.2' = {
  scope: workloadResourceGroup
  name: '${uniqueString(deployment().name, location)}-vm-${name}'
  params: {
    name: name
    computerName: name
    adminUsername: 'SysAdmin'
    adminPassword: 'P@ssw0rd1234!'
    tags: {
      'hidden-title': 'Workload Desktop'
      Environment: 'Non-Prod'
      Role: 'Workload Desktop'
    }
    imageReference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2019-datacenter'
      version: 'latest'
    }
    nicConfigurations: [
      {
        deleteOption: 'Delete'
        ipConfigurations: [
          {
            applicationSecurityGroups: [
              {
                id: applicationSecurityGroup.outputs.resourceId
              }
            ]
            loadBalancerBackendAddressPools: [
              {
                id: loadBalancer.outputs.backendpools[0].id
              }
            ]
            name: 'ipconfig01'
            pipConfiguration: {
              publicIpNameSuffix: '-pip-01'
              zones: [
                1
                2
                3
              ]
              roleAssignments: [
                {
                  roleDefinitionIdOrName: 'Reader'
                  principalId: managedIdentity.outputs.principalId
                  principalType: 'ServicePrincipal'
                }
              ]
            }
            subnetResourceId: virtualNetwork.outputs.subnetResourceIds[0]
            diagnosticSettings: [
              {
                name: 'customSetting'
                metricCategories: [
                  {
                    category: 'AllMetrics'
                  }
                ]
                eventHubName: eventHubName
                eventHubAuthorizationRuleResourceId: eventHubAuthorizationRuleResourceId
                storageAccountResourceId: storageAccountResourceId
                workspaceResourceId: workspaceResourceId
              }
            ]
          }
        ]
        nicSuffix: '-nic-01'
        roleAssignments: [
          {
            roleDefinitionIdOrName: 'Reader'
            principalId: managedIdentity.outputs.principalId
            principalType: 'ServicePrincipal'
          }
        ]
        diagnosticSettings: [
          {
            name: 'customSetting'
            metricCategories: [
              {
                category: 'AllMetrics'
              }
            ]
            eventHubName: eventHubName
            eventHubAuthorizationRuleResourceId: eventHubAuthorizationRuleResourceId
            storageAccountResourceId: storageAccountResourceId
            workspaceResourceId: workspaceResourceId
          }
        ]
      }
    ]
    osDisk: {
      caching: 'ReadWrite'
      createOption: 'FromImage'
      deleteOption: 'Delete'
      diskSizeGB: 128
      managedDisk: {
        storageAccountType: 'Premium_LRS'
      }
    }
    osType: 'Windows'
    vmSize: 'Standard_DS2_v2'
    zone: 0
    dataDisks: [
      {
        caching: 'ReadOnly'
        createOption: 'Empty'
        deleteOption: 'Delete'
        diskSizeGB: 128
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
    ]
    enableAutomaticUpdates: true
    patchMode: 'AutomaticByPlatform'
    encryptionAtHost: false
    backupPolicyName: 'vmBackupPolicy'
    backupVaultResourceGroup: recoveryServices.outputs.resourceGroupName
    backupVaultName: recoveryServices.outputs.name
    autoShutdownConfig: {
      status: 'Enabled'
      dailyRecurrenceTime: '19:00'
      timeZone: 'UTC'
      notificationStatus: 'Enabled'
      notificationEmail: 'damian.flynn@innofactor.com'
      notificationLocale: 'en'
      notificationTimeInMinutes: 30
    }
    extensionMonitoringAgentConfig: {
      enabled: true
      tags: {
        'hidden-title': 'This is visible in the resource name'
        Environment: 'Non-Prod'
        Role: 'DeploymentValidation'
      }
    }
    extensionNetworkWatcherAgentConfig: {
      enabled: true
      tags: {
        'hidden-title': 'This is visible in the resource name'
        Environment: 'Non-Prod'
        Role: 'DeploymentValidation'
      }
    }
    lock: {
      kind: 'CanNotDelete'
      name: 'myCustomLockName'
    }
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Owner'
        principalId: managedIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
      }
      {
        roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
        principalId: managedIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
      }
      {
        roleDefinitionIdOrName: subscriptionResourceId(
          'Microsoft.Authorization/roleDefinitions',
          'acdd72a7-3385-48ef-bd42-f606fba81ae7'
        )
        principalId: managedIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
      }
    ]
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: [
        managedIdentity.outputs.resourceId
      ]
    }
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
