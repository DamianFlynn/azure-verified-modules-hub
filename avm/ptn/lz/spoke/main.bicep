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

@description('Optional. The lock settings of the service.')
param lock lockType

@description('Optional. Tags of the resource.')
param tags object?

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

@description('Optional. Enable Recovery Vault Disaster Recovery replications.')
param enableBCDR bool = false

@description('Optional. The resource ID of an auding function.')
param azureActivitiesSink string = ''

@description('Optional. The IP Address of the Hub Firewall.')
param hubFirewallPrivateIp string = '10.1.1.4'

@description('Optional. The Partner ID for partner attribution.')
param partnerCountry string = 'norway'

var defaultTag = {
  iacVersion: loadJsonContent('./version.json').version
  iacTemplate: loadJsonContent('./version.json').name
}

var tagResources = union(defaultTag, tags)

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

resource iacTelemetry 'Microsoft.Resources/deployments@2024-03-01' = {
  name: ((partnerCountry == 'Denmark')
    ? 'pid-5d59d69c-bc64-4dfd-b56f-d5b6d008d08d'
    : ((partnerCountry == 'Sweden')
        ? 'pid-d132969b-6f95-5ad0-a909-c2c2f3caf9ab'
        : ((partnerCountry == 'Finland')
            ? 'pid-d40f4895-5a21-5612-aa15-69cd25571694'
            : 'pid-d40f4895-5a21-5612-aa15-69cd25571694')))
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
          value: 'For more information, see https://aka.ms/PartnerAttribution'
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
  name: '${uniqueString(deployment().name, location)}-sub-securityCenter-${name}'
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
    autoProvision: 'On'
    appServicesPricingTier: 'Free'
    armPricingTier: 'Free'
    containerRegistryPricingTier: 'Free'
    containersTier: 'Free'
    cosmosDbsTier: 'Free'
    dnsPricingTier: 'Free'
    keyVaultsPricingTier: 'Free'
    kubernetesServicePricingTier: 'Free'
    openSourceRelationalDatabasesTier: 'Free'
    sqlServersPricingTier: 'Free'
    sqlServerVirtualMachinesPricingTier: 'Free'
    storageAccountsPricingTier: 'Free'
    virtualMachinesPricingTier: 'Free'
  }
}

// module policySetAssignments 'br/public:avm/ptn/authorization/policy-assignment:0.1.0' = {
//   // scope: '/subscriptions/${subscription().subscriptionId}'
//   scope: managementGroup('vdc')
//   name: '${uniqueString(deployment().name)}-sub-policySetAssignment-sub'
//   params: {
//     name: '[GOV]: VDC Governance (${subscription().displayName} subscription)'
//     subscriptionId: subscription().subscriptionId
//     location: location
//     policyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/12794019-7a00-42cf-95c2-882eed337cc8'
//     parameters: {
//       existEffect: {
//         value: 'Deny'
//       }
//       listOfAllowedVMSKUs: {
//         value: [
//           'Standard_A1_v2'
//           'Standard_A2_v2'
//           'Standard_A4_v2'
//           'Standard_B1s'
//           'Standard_B1ms'
//           'Standard_B2s'
//           'Standard_B2ms'
//           'Standard_B4ms'
//           'Standard_D1_v2'
//           'Standard_D2s_v3'
//           'Standard_D2s_v4'
//           'Standard_D4s_v4'
//           'Standard_DS1_v2'
//           'Standard_DS2_v2'
//           'Standard_D3_v2'
//           'Standard_DS3_v2'
//           'Standard_F1s'
//           'Standard_F2s_v2'
//           'Standard_F4s_v2'
//         ]
//       }
//       listOfAllowedStoreSKUs: {
//         value: [
//           'Standard_LRS'
//           'Standard_GRS'
//           'Standard_ZRS'
//           'Premium_LRS'
//           'Premium_ZRS'
//         ]
//       }
//     }
//     enforcementMode: 'Default'
//     metadata: {
//       category: 'Security'
//       version: '1.0'
//       assignedBy: 'Bicep'
//     }
//   }
// }

resource auditResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${name}-audit'
  location: location
  tags: union(tagResources, {
    'hidden-title': 'Governance: Auditing '
    Role: 'Goverance'
  })
}

module systemTopic 'br/public:avm/res/event-grid/system-topic:0.2.6' = {
  scope: auditResourceGroup
  name: '${uniqueString(deployment().name, location)}-audit-SystemTopic-${name}'
  params: {
    location: 'global'
    name: '${name}-audit-governance-egst'
    tags: union(tagResources, {
      'hidden-title': 'Governance: Auditing Events'
      Role: 'Governance'
    })
    source: subscription().id
    topicType: 'microsoft.resources.subscriptions'
    lock: lock
    diagnosticSettings: (!empty(storageAccountResourceId) && !empty(workspaceResourceId))
      ? [
          {
            name: '${name}-diagnostics'
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
      : []
    eventSubscriptions: !empty(azureActivitiesSink)
      ? [
          {
            name: 'governance'
            destination: {
              endpointType: 'AzureFunction'
              properties: {
                resourceId: azureActivitiesSink
                maxEventsPerBatch: 1
                preferredBatchSizeInKilobytes: 64
                deliveryAttributeMappings: []
              }
            }
            retryPolicy: {
              maxDeliveryAttempts: 30
              eventTimeToLiveInMinutes: 1440
            }
            filter: {
              includedEventTypes: [
                'Microsoft.Resources.ResourceWriteSuccess'
              ]
              advancedFilters: [
                {
                  values: [
                    'Microsoft.Resources/tags/write'
                    'Microsoft.Resources/deployments/write'
                    'Microsoft.Security/policies/write'
                    'Microsoft.Authorization/locks/write'
                    'Microsoft.Authorization/roleAssignments/write'
                    'microsoft.insights/diagnosticSettings/write'
                    'Microsoft.EventGrid/systemTopics/eventSubscriptions/write'
                    'Microsoft.Web/sites/Extensions/write'
                    'Microsoft.Web/sites/host/functionKeys/write'
                    'Microsoft.Compute/restorePointCollections/restorePoints/write'
                    'Microsoft.OperationalInsights/workspaces/linkedServices/write'
                    'Microsoft.Security/workspaceSettings/write'
                    'Microsoft.Security/pricings/write'
                  ]
                  operatorType: 'StringNotContains'
                  key: 'data.operationName'
                }
              ]
            }
            labels: [
              'functions-event_azureactivitiessink'
            ]
            eventDeliverySchema: 'EventGridSchema'
          }
        ]
      : []
  }
}

// Network resources
// =================

resource networkResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${name}-net'
  location: location
  tags: union(tagResources, {
    'hidden-title': '${name} Networking'
    Role: 'Networking'
  })
}

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.1.6' = {
  scope: networkResourceGroup
  name: '${uniqueString(deployment().name, location)}-network-vnet-${name}'
  params: {
    name: '${name}-vnet'
    tags: union(tagResources, {
      'hidden-title': '${name} Networking'
      Role: 'Networking'
    })
    addressPrefixes: [
      addressPrefix
    ]
    flowTimeoutInMinutes: 20
    subnets: [
      {
        addressPrefix: cidrSubnet(addressPrefix, 25, 0)
        name: 'FrontendSubnet'
        networkSecurityGroupResourceId: frontendNetworkSecruityGroups.outputs.resourceId
        routeTableResourceId: frontendRouteTable_Resource.outputs.resourceId
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
      }
      {
        addressPrefix: cidrSubnet(addressPrefix, 25, 1)
        name: 'BackendSubnet'
        networkSecurityGroupResourceId: backendNetworkSecruityGroups.outputs.resourceId
        routeTableResourceId: backendRouteTable_Resource.outputs.resourceId
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
        serviceEndpoints: [
          {
            service: 'Microsoft.Storage'
          }
        ]
      }
    ]
    lock: lock
    diagnosticSettings: (!empty(storageAccountResourceId) && !empty(workspaceResourceId))
      ? [
          {
            name: '${name}-diagnostics'
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
      : []
  }
}

module nsgFlowLogsStorage_Resource 'br/public:avm/res/storage/storage-account:0.9.0' = {
  scope: networkResourceGroup
  name: '${uniqueString(deployment().name, location)}-network-FlowLogStorage-${name}'
  params: {
    name: '${name}vnetstorage'
    location: location
    tags: union(tagResources, {
      'hidden-title': '${name} Networking'
      Role: 'Networking'
    })
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
    lock: lock
    diagnosticSettings: (!empty(storageAccountResourceId) && !empty(workspaceResourceId))
      ? [
          {
            name: '${name}-diagnostics'
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
      : []
  }
}

module networkWatcher 'br/public:avm/res/network/network-watcher:0.1.1' = {
  scope: networkResourceGroup
  name: '${uniqueString(deployment().name, location)}-network-watcher-${name}'
  params: {
    name: '${name}-nw'
    tags: union(tagResources, {
      'hidden-title': '${name} Networking'
      Role: 'Networking'
    })
    flowLogs: [
      {
        enabled: false
        formatVersion: 2
        name: '${name}-fl-backend'
        retentionInDays: 8
        storageId: nsgFlowLogsStorage_Resource.outputs.resourceId
        targetResourceId: frontendNetworkSecruityGroups.outputs.resourceId
        trafficAnalyticsInterval: 10
        workspaceResourceId: workspaceResourceId
      }
      {
        formatVersion: 2
        name: '${name}-fl-backend'
        retentionInDays: 8
        storageId: nsgFlowLogsStorage_Resource.outputs.resourceId
        targetResourceId: backendNetworkSecruityGroups.outputs.resourceId
        trafficAnalyticsInterval: 10
        workspaceResourceId: workspaceResourceId
      }
    ]
    lock: lock
  }
}

module frontendRouteTable_Resource 'br/public:avm/res/network/route-table:0.2.2' = {
  scope: networkResourceGroup
  name: '${uniqueString(deployment().name, location)}-network-frontRT-${name}'
  params: {
    enableTelemetry: false
    name: '${name}-FrontendSubnet-RT'
    tags: union(tagResources, {
      'hidden-title': '${name} Networking Route Table'
      Role: 'Networking'
    })
    routes: [
      {
        name: 'Everywhere'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopIpAddress: hubFirewallPrivateIp
          nextHopType: 'VirtualAppliance'
        }
      }
    ]
    lock: lock
  }
}

module frontendNetworkSecruityGroups 'br/public:avm/res/network/network-security-group:0.1.3' = {
  scope: networkResourceGroup
  name: '${uniqueString(deployment().name, location)}-network-frontNSG-${name}'
  params: {
    name: '${name}-FrontendSubnet-nsg'
    tags: union(tagResources, {
      'hidden-title': '${name} Networking ACL'
      Role: 'Networking'
    })
    securityRules: [
      {
        name: 'AllowDnsFromFirewallToFrontendsubnet'
        properties: {
          description: 'Allow DNS queries from the Azure Firewall'
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '53'
          sourceAddressPrefix: hubFirewallPrivateIp
          destinationAddressPrefix: cidrSubnet(addressPrefix, 25, 0)
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowProbeFromAzureloadbalancerToFrontendsubnet'
        properties: {
          description: 'Allow probe from Azure Load Balancer to the Frontend Subnet'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: cidrSubnet(addressPrefix, 25, 0)
          access: 'Allow'
          priority: 3900
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAll'
        properties: {
          access: 'Deny'
          description: 'Default rule to deny all inbound traffic'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          direction: 'Inbound'
          priority: 4000
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
    ]
    lock: lock
    diagnosticSettings: (!empty(storageAccountResourceId) && !empty(workspaceResourceId))
      ? [
          {
            name: '${name}-diagnostics'
            metricCategories: [
              {
                category: 'NetworkSecurityGroupEvent'
              }
              {
                category: 'NetworkSecurityGroupRuleCounter'
              }
            ]
            eventHubName: eventHubName
            eventHubAuthorizationRuleResourceId: eventHubAuthorizationRuleResourceId
            storageAccountResourceId: storageAccountResourceId
            workspaceResourceId: workspaceResourceId
          }
        ]
      : []
  }
}

module backendRouteTable_Resource 'br/public:avm/res/network/route-table:0.2.2' = {
  scope: networkResourceGroup
  name: '${uniqueString(deployment().name, location)}-network-backRT-${name}'
  params: {
    enableTelemetry: false
    name: '${name}-BackendSubnet-RT'
    tags: union(tagResources, {
      'hidden-title': '${name} Networking Route Table'
      Role: 'Networking'
    })
    routes: [
      {
        name: 'Everywhere'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopIpAddress: hubFirewallPrivateIp
          nextHopType: 'VirtualAppliance'
        }
      }
    ]
    lock: lock
  }
}

module backendNetworkSecruityGroups 'br/public:avm/res/network/network-security-group:0.1.3' = {
  scope: networkResourceGroup
  name: '${uniqueString(deployment().name, location)}-network-backNSG-${name}'
  params: {
    name: '${name}-BackendSubnet-nsg'
    tags: union(tagResources, {
      'hidden-title': '${name} Networking ACL'
      Role: 'Networking'
    })
    securityRules: [
      {
        name: 'AllowDnsFromDcsubnetToBackendsubnet'
        properties: {
          description: 'Allow DNS replies from the domain controllers'
          protocol: 'Udp'
          sourceAddressPrefix: '10.1.8.0/26'
          sourcePortRange: '*'
          destinationAddressPrefix: cidrSubnet(addressPrefix, 25, 1)
          destinationPortRange: '53'
          access: 'Allow'
          priority: 1200
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowProbeFromAzureloadbalancerToBackendsubnet'
        properties: {
          description: 'Allow probe from Azure Load Balancer to the Backend Subnet'
          protocol: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          sourcePortRange: '*'
          destinationAddressPrefix: cidrSubnet(addressPrefix, 25, 1)
          destinationPortRange: '*'
          access: 'Allow'
          priority: 3900
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAll'
        properties: {
          access: 'Deny'
          description: 'Default rule to deny all inbound traffic'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          direction: 'Inbound'
          priority: 4000
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
    ]
    lock: lock
    diagnosticSettings: (!empty(storageAccountResourceId) && !empty(workspaceResourceId))
      ? [
          {
            name: '${name}-diagnostics'
            metricCategories: [
              {
                category: 'NetworkSecurityGroupEvent'
              }
              {
                category: 'NetworkSecurityGroupRuleCounter'
              }
            ]
            eventHubName: eventHubName
            eventHubAuthorizationRuleResourceId: eventHubAuthorizationRuleResourceId
            storageAccountResourceId: storageAccountResourceId
            workspaceResourceId: workspaceResourceId
          }
        ]
      : []
  }
}

module applicationSecurityGroup 'br/public:avm/res/network/application-security-group:0.1.3' = {
  scope: networkResourceGroup
  name: '${uniqueString(deployment().name, location)}-network-appSG-${name}'
  params: {
    name: '${name}-asg'
    tags: union(tagResources, {
      'hidden-title': '${name} Networking Group'
      Role: 'Networking'
    })
    lock: lock
  }
}

// General resources
// =================

resource workloadResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: name
  location: location
  tags: union(tagResources, {
    'hidden-title': '${name} Workload'
    Role: 'Workload'
  })
}

module managedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.2.1' = {
  scope: workloadResourceGroup
  name: '${uniqueString(deployment().name, location)}-workload-mi-${name}'
  params: {
    name: '${name}-mi'
    tags: union(tagResources, {
      'hidden-title': '${name} Workload Identity'
      Role: 'Workload'
    })
    lock: lock
  }
}

module loadBalancer 'br/public:avm/res/network/load-balancer:0.1.4' = {
  scope: workloadResourceGroup
  name: '${uniqueString(deployment().name, location)}-workload-ilb-${name}'
  params: {
    name: '${name}-lb'
    tags: union(tagResources, {
      'hidden-title': '${name} Workload Ballancer'
      Role: 'Workload'
    })

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
        name: 'HTTPS'
        protocol: 'Tcp'
      }
      {
        backendPort: 3389
        frontendIPConfigurationName: '${name}-lb-privateIP'
        frontendPort: 3389
        name: 'RDP'
      }
      {
        backendPort: 22
        frontendIPConfigurationName: '${name}-lb-privateIP'
        frontendPort: 22
        name: 'SSH'
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
    lock: lock
    diagnosticSettings: (!empty(storageAccountResourceId) && !empty(workspaceResourceId))
      ? [
          {
            name: '${name}-diagnostics'
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
      : []
  }
}

module recoveryServices 'br/public:avm/res/recovery-services/vault:0.2.1' = {
  scope: workloadResourceGroup
  name: '${uniqueString(deployment().name, location)}-workload-recovery-${name}'
  params: {
    name: '${name}-rs'
    tags: union(tagResources, {
      'hidden-title': '${name} Workload Recovery'
      Role: 'Workload'
    })

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
    replicationFabrics: !enableBCDR
      ? [
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
      : []
    replicationPolicies: !enableBCDR
      ? [
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
      : []
    lock: lock
    diagnosticSettings: (!empty(storageAccountResourceId) && !empty(workspaceResourceId))
      ? [
          {
            name: '${name}-diagnostics'
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
      : []
  }
}

module virtualMachine 'br/public:avm/res/compute/virtual-machine:0.4.2' = {
  scope: workloadResourceGroup
  name: '${uniqueString(deployment().name, location)}-workload-vm-${name}'
  params: {
    name: name
    computerName: name
    adminUsername: 'SysAdmin'
    adminPassword: 'P@ssw0rd1234!'
    tags: union(tagResources, {
      'hidden-title': '${name} Workload VM'
      Role: 'Workload'
    })

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
                name: 'ipconfig01Diagnostic'
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
            name: 'nicDiagnosticsSetting'
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
      tags: union(tagResources, {
        'hidden-title': '${name} Workload VM Monitoring'
        Role: 'Workload'
      })
    }
    extensionNetworkWatcherAgentConfig: {
      enabled: true
      tags: union(tagResources, {
        'hidden-title': '${name} Workload Watcher'
        Role: 'Workload'
      })
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
    lock: lock
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

type lockType = {
  @description('Optional. Specify the name of lock.')
  name: string?

  @description('Optional. Specify the type of lock.')
  kind: ('CanNotDelete' | 'ReadOnly' | 'None')?
}?
