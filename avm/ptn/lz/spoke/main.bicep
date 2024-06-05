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
@description('Optional. The IP Address of the Hub Firewall.')
param hubFirewallPrivateIp string = '10.1.1.4'

@description('Optional. The address prefix for the virtual network.')
param addressPrefix string = '10.0.0.0/24'

@description('Optional. An array of routes to be established within the hub route table.')
param routes routeType

@description('Optional. Array of Security Rules to deploy to the Frontend Network Security Group. When not provided, an NSG including only the default rules will be deployed.')
param frontendSecurityRules array = []

@description('Optional. Array of Security Rules to deploy to the Backend Network Security Group. When not provided, an NSG including only the default rules will be deployed.')
param backendSecurityRules array = []

@description('Optional. The event hub namespace name.')
param eventHubName string = ''

@description('Optional. The event hub authorization rule resource ID.')
param eventHubAuthorizationRuleResourceId string = ''

@description('Optional. The storage account resource ID.')
param storageAccountResourceId string = ''

@description('Optional. The log analytics workspace resource ID.')
param workspaceResourceId string = ''

@description('Optional. The resource ID of an auding function.')
param azureActivitiesSink string = ''

@description('Optional. The Partner ID for partner attribution.')
param partnerCountry string = 'norway'

// This pattern has opinionated defaults for the tags that are applied to all resources
// providing a tags parameter will merge supplied tags to this default configuration
var defaultTag = {
  iacVersion: loadJsonContent('./version.json').version
  iacTemplate: loadJsonContent('./version.json').name
}
var tagResources = union(defaultTag, tags)

// This pattern has opinionated defaults for the traffic flow from the spoke to the hub
// providing a routes paramater will replace this default configuration
var defaultRoutes = [
  {
    name: 'Everywhere'
    properties: {
      addressPrefix: '0.0.0.0/0'
      nextHopIpAddress: hubFirewallPrivateIp
      nextHopType: 'VirtualAppliance'
    }
  }
]

// This pattern has opinionated defaults for the security rules for the frontend and backend subnets
// providing a frontendSecurityRules or backendSecurityRules parameter will append those rules to
// this default configuration. The Union function is used to ensure that the default rules are
// always included in the final configuration.

var defaultFrontendNsgRules = [
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

var defaultBackendNsgRules = [
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
  name: '${name}.sub.seuritycenter.${uniqueString(deployment().name, location)}'
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
  name: '${name}.sub.auditRg.res.systemTopic.${uniqueString(deployment().name, location)}'
  params: {
    location: 'global'
    name: '${auditResourceGroup.name}-topic'
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
            name: '${auditResourceGroup.name}-topic-diag'
            metricCategories: [
              {
                category: 'AllMetrics'
              }
            ]
            eventHubName: eventHubName
            eventHubAuthorizationRuleResourceId: eventHubAuthorizationRuleResourceId
            // storageAccountResourceId: storageAccountResourceId
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

module frontendNetworkSecruityGroups 'br/public:avm/res/network/network-security-group:0.1.3' = {
  scope: networkResourceGroup
  name: '${name}.sub.networkRg.res.frontendNsg.${uniqueString(deployment().name, location)}'
  params: {
    name: '${name}-FrontendSubnet-nsg'
    tags: union(tagResources, {
      'hidden-title': '${name} Networking ACL'
      Role: 'Networking'
    })
    securityRules: !empty(frontendSecurityRules)
      ? union(frontendSecurityRules, defaultFrontendNsgRules)
      : defaultFrontendNsgRules
    lock: lock
    diagnosticSettings: (!empty(storageAccountResourceId) && !empty(workspaceResourceId))
      ? [
          {
            name: '${name}-nsg-frontend-diagnostics'
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

module frontendRouteTable 'br/public:avm/res/network/route-table:0.2.2' = {
  scope: networkResourceGroup
  name: '${name}.sub.networkRg.res.frontendRT.${uniqueString(deployment().name, location)}'
  params: {
    enableTelemetry: false
    name: '${name}-FrontendSubnet-rt'
    tags: union(tagResources, {
      'hidden-title': '${name} Networking Route Table'
      Role: 'Networking'
    })
    routes: !empty(routes) ? routes : defaultRoutes
    lock: lock
  }
}
module backendNetworkSecruityGroups 'br/public:avm/res/network/network-security-group:0.1.3' = {
  scope: networkResourceGroup
  name: '${name}.sub.networkRg.res.backendNsg.${uniqueString(deployment().name, location)}'
  params: {
    name: '${name}-BackendSubnet-nsg'
    tags: union(tagResources, {
      'hidden-title': '${name} Networking ACL'
      Role: 'Networking'
    })
    securityRules: !empty(backendSecurityRules)
      ? union(backendSecurityRules, defaultBackendNsgRules)
      : defaultBackendNsgRules
    lock: lock
    diagnosticSettings: (!empty(storageAccountResourceId) && !empty(workspaceResourceId))
      ? [
          {
            name: '${name}-nsg-backend-diagnostics'
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

module backendRouteTable 'br/public:avm/res/network/route-table:0.2.2' = {
  scope: networkResourceGroup
  name: '${name}.sub.networkRg.res.backendRt.${uniqueString(deployment().name, location)}'
  params: {
    enableTelemetry: false
    name: '${name}-BackendSubnet-rt'
    tags: union(tagResources, {
      'hidden-title': '${name} Networking Route Table'
      Role: 'Networking'
    })
    routes: !empty(routes) ? routes : defaultRoutes
    lock: lock
  }
}

module networkWatcher 'br/public:avm/res/network/network-watcher:0.1.1' = {
  scope: networkResourceGroup
  name: '${name}.sub.networkRg.res.networkWatcher.${uniqueString(deployment().name, location)}'
  params: {
    name: '${name}-networkwatcher'
    tags: union(tagResources, {
      'hidden-title': '${name} Networking'
      Role: 'Networking'
    })
    flowLogs: [
      {
        enabled: false
        formatVersion: 2
        name: '${name}-fl-frontend'
        retentionInDays: 8
        storageId: nsgFlowlogsStorage.outputs.resourceId
        targetResourceId: frontendNetworkSecruityGroups.outputs.resourceId
        trafficAnalyticsInterval: 10
        workspaceResourceId: workspaceResourceId
      }
      {
        formatVersion: 2
        name: '${name}-fl-backend'
        retentionInDays: 8
        storageId: nsgFlowlogsStorage.outputs.resourceId
        targetResourceId: backendNetworkSecruityGroups.outputs.resourceId
        trafficAnalyticsInterval: 10
        workspaceResourceId: workspaceResourceId
      }
    ]
    lock: lock
  }
}

module nsgFlowlogsStorage 'br/public:avm/res/storage/storage-account:0.9.0' = {
  scope: networkResourceGroup
  name: '${name}.sub.networkRg.res.FlowlogsStorage.${uniqueString(deployment().name, location)}'
  params: {
    name: take(replace(replace('${name}vnetflowlogstg', '-', ''), '_', ''), 24)
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
            name: '${name}-nsg-flow-diagnostics'
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

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.1.6' = {
  scope: networkResourceGroup
  name: '${name}.sub.networkRg.res.virtualNetwork.${uniqueString(deployment().name, location)}'
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
        routeTableResourceId: frontendRouteTable.outputs.resourceId
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
      }
      {
        addressPrefix: cidrSubnet(addressPrefix, 25, 1)
        name: 'BackendSubnet'
        networkSecurityGroupResourceId: backendNetworkSecruityGroups.outputs.resourceId
        routeTableResourceId: backendRouteTable.outputs.resourceId
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
            name: '${name}-vnet-diagnostics'
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

// ============ //
// Outputs      //
// ============ //

// Add your outputs here

// @description('The resource ID of the resource.')
// output resourceId string = <Resource>.id

@description('The name of the virtual network.')
output name string = virtualNetwork.name

@description('The location the resource was deployed into.')
output location string = virtualNetwork.outputs.location

@description('The names of the deployed subnets.')
output subnetNames array = virtualNetwork.outputs.subnetNames

@description('The resource ID of the deployed virtual network.')
output virtualNetworkResourceId string = virtualNetwork.outputs.resourceId

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

type routeType = {
  @description('Required. Name of the route.')
  name: string

  @description('Required. Properties of the route.')
  properties: {
    @description('Required. The type of Azure hop the packet should be sent to.')
    nextHopType: ('VirtualAppliance' | 'VnetLocal' | 'Internet' | 'VirtualNetworkGateway' | 'None')

    @description('Optional. The destination CIDR to which the route applies.')
    addressPrefix: string?

    @description('Optional. A value indicating whether this route overrides overlapping BGP routes regardless of LPM.')
    hasBgpOverride: bool?

    @description('Optional. The IP address packets should be forwarded to. Next hop values are only allowed in routes where the next hop type is VirtualAppliance.')
    nextHopIpAddress: string?
  }
}[]?
