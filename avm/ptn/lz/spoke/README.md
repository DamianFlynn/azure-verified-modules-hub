# Spoke Landing Zone with Virtual Machine `[Microsoft.lz/spoke]`

This Instance deploys a Spoke Landing Zone with Virtual Machine

## Navigation

- [Resource Types](#Resource-Types)
- [Usage examples](#Usage-examples)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Cross-referenced modules](#Cross-referenced-modules)
- [Data Collection](#Data-Collection)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Authorization/locks` | [2020-05-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2020-05-01/locks) |
| `Microsoft.Authorization/roleAssignments` | [2022-04-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2022-04-01/roleAssignments) |
| `Microsoft.EventGrid/systemTopics` | [2023-12-15-preview](https://learn.microsoft.com/en-us/azure/templates/Microsoft.EventGrid/2023-12-15-preview/systemTopics) |
| `Microsoft.EventGrid/systemTopics/eventSubscriptions` | [2023-12-15-preview](https://learn.microsoft.com/en-us/azure/templates/Microsoft.EventGrid/2023-12-15-preview/systemTopics/eventSubscriptions) |
| `Microsoft.Insights/diagnosticSettings` | [2021-05-01-preview](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Insights/2021-05-01-preview/diagnosticSettings) |
| `Microsoft.Network/networkSecurityGroups` | [2023-04-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-04-01/networkSecurityGroups) |
| `Microsoft.Network/networkSecurityGroups/securityRules` | [2023-04-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-04-01/networkSecurityGroups/securityRules) |
| `Microsoft.Network/networkWatchers` | [2023-04-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-04-01/networkWatchers) |
| `Microsoft.Network/networkWatchers/connectionMonitors` | [2023-04-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-04-01/networkWatchers/connectionMonitors) |
| `Microsoft.Network/networkWatchers/flowLogs` | [2023-04-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-04-01/networkWatchers/flowLogs) |
| `Microsoft.Network/privateEndpoints` | [2023-04-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-04-01/privateEndpoints) |
| `Microsoft.Network/privateEndpoints/privateDnsZoneGroups` | [2023-04-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-04-01/privateEndpoints/privateDnsZoneGroups) |
| `Microsoft.Network/routeTables` | [2023-04-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-04-01/routeTables) |
| `Microsoft.Network/virtualNetworks` | [2023-04-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-04-01/virtualNetworks) |
| `Microsoft.Network/virtualNetworks/subnets` | [2023-04-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-04-01/virtualNetworks/subnets) |
| `Microsoft.Network/virtualNetworks/virtualNetworkPeerings` | [2023-04-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-04-01/virtualNetworks/virtualNetworkPeerings) |
| `Microsoft.Resources/resourceGroups` | [2021-04-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Resources/2021-04-01/resourceGroups) |
| `Microsoft.Security/autoProvisioningSettings` | [2017-08-01-preview](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Security/2017-08-01-preview/autoProvisioningSettings) |
| `Microsoft.Security/deviceSecurityGroups` | [2019-08-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Security/2019-08-01/deviceSecurityGroups) |
| `Microsoft.Security/iotSecuritySolutions` | [2019-08-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Security/2019-08-01/iotSecuritySolutions) |
| `Microsoft.Security/pricings` | [2018-06-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Security/2018-06-01/pricings) |
| `Microsoft.Security/securityContacts` | [2017-08-01-preview](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Security/2017-08-01-preview/securityContacts) |
| `Microsoft.Security/workspaceSettings` | [2017-08-01-preview](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Security/2017-08-01-preview/workspaceSettings) |
| `Microsoft.Storage/storageAccounts` | [2022-09-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/2022-09-01/storageAccounts) |
| `Microsoft.Storage/storageAccounts/blobServices` | [2022-09-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/2022-09-01/storageAccounts/blobServices) |
| `Microsoft.Storage/storageAccounts/blobServices/containers` | [2022-09-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/2022-09-01/storageAccounts/blobServices/containers) |
| `Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies` | [2022-09-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/2022-09-01/storageAccounts/blobServices/containers/immutabilityPolicies) |
| `Microsoft.Storage/storageAccounts/fileServices` | [2023-04-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/storageAccounts/fileServices) |
| `Microsoft.Storage/storageAccounts/fileServices/shares` | [2023-01-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/2023-01-01/storageAccounts/fileServices/shares) |
| `Microsoft.Storage/storageAccounts/localUsers` | [2023-04-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/storageAccounts/localUsers) |
| `Microsoft.Storage/storageAccounts/managementPolicies` | [2023-01-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/2023-01-01/storageAccounts/managementPolicies) |
| `Microsoft.Storage/storageAccounts/queueServices` | [2023-04-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/storageAccounts/queueServices) |
| `Microsoft.Storage/storageAccounts/queueServices/queues` | [2023-04-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/storageAccounts/queueServices/queues) |
| `Microsoft.Storage/storageAccounts/tableServices` | [2023-04-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/storageAccounts/tableServices) |
| `Microsoft.Storage/storageAccounts/tableServices/tables` | [2023-04-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/storageAccounts/tableServices/tables) |

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

>**Note**: To reference the module, please use the following syntax `br/public:avm/ptn/lz/spoke:<version>`.

- [Spoke Landing Zone with Virtual Machine WAF Aligned](#example-1-spoke-landing-zone-with-virtual-machine-waf-aligned)
- [Spoke Landing Zone with Virtual Machine WAF Aligned](#example-2-spoke-landing-zone-with-virtual-machine-waf-aligned)

### Example 1: _Spoke Landing Zone with Virtual Machine WAF Aligned_

This module deploys an Azure Continer Registry using minimal parameters.


<details>

<summary>via Bicep module</summary>

```bicep
module spoke 'br/public:avm/ptn/lz/spoke:<version>' = {
  name: 'spokeDeployment'
  params: {
    // Required parameters
    location: '<location>'
    name: '<name>'
    // Non-required parameters
    addressPrefix: '<addressPrefix>'
    eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
    eventHubName: '<eventHubName>'
    frontendSecurityRules: [
      {
        name: 'AllowRdoFromFirewallToFrontendsubnet'
        properties: {
          access: 'Allow'
          description: 'Allow RDP Connections from the Azure Firewall'
          destinationAddressPrefix: '<destinationAddressPrefix>'
          destinationPortRange: '3389'
          direction: 'Inbound'
          priority: 1100
          protocol: 'Udp'
          sourceAddressPrefix: '10.1.1.4'
          sourcePortRange: '*'
        }
      }
    ]
    storageAccountResourceId: '<storageAccountResourceId>'
    tags: {
      Environment: 'Non-Prod'
      Role: 'DeploymentValidation'
    }
    workspaceResourceId: '<workspaceResourceId>'
  }
}
```

</details>
<p>

<details>

<summary>via JSON Parameter file</summary>

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    // Required parameters
    "location": {
      "value": "<location>"
    },
    "name": {
      "value": "<name>"
    },
    // Non-required parameters
    "addressPrefix": {
      "value": "<addressPrefix>"
    },
    "eventHubAuthorizationRuleResourceId": {
      "value": "<eventHubAuthorizationRuleResourceId>"
    },
    "eventHubName": {
      "value": "<eventHubName>"
    },
    "frontendSecurityRules": {
      "value": [
        {
          "name": "AllowRdoFromFirewallToFrontendsubnet",
          "properties": {
            "access": "Allow",
            "description": "Allow RDP Connections from the Azure Firewall",
            "destinationAddressPrefix": "<destinationAddressPrefix>",
            "destinationPortRange": "3389",
            "direction": "Inbound",
            "priority": 1100,
            "protocol": "Udp",
            "sourceAddressPrefix": "10.1.1.4",
            "sourcePortRange": "*"
          }
        }
      ]
    },
    "storageAccountResourceId": {
      "value": "<storageAccountResourceId>"
    },
    "tags": {
      "value": {
        "Environment": "Non-Prod",
        "Role": "DeploymentValidation"
      }
    },
    "workspaceResourceId": {
      "value": "<workspaceResourceId>"
    }
  }
}
```

</details>
<p>

### Example 2: _Spoke Landing Zone with Virtual Machine WAF Aligned_

This module deploys an Azure Continer Registry using minimal parameters.


<details>

<summary>via Bicep module</summary>

```bicep
module spoke 'br/public:avm/ptn/lz/spoke:<version>' = {
  name: 'spokeDeployment'
  params: {
    // Required parameters
    location: '<location>'
    name: 'lzwaf001'
    // Non-required parameters
    eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
    eventHubName: '<eventHubName>'
    storageAccountResourceId: '<storageAccountResourceId>'
    workspaceResourceId: '<workspaceResourceId>'
  }
}
```

</details>
<p>

<details>

<summary>via JSON Parameter file</summary>

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    // Required parameters
    "location": {
      "value": "<location>"
    },
    "name": {
      "value": "lzwaf001"
    },
    // Non-required parameters
    "eventHubAuthorizationRuleResourceId": {
      "value": "<eventHubAuthorizationRuleResourceId>"
    },
    "eventHubName": {
      "value": "<eventHubName>"
    },
    "storageAccountResourceId": {
      "value": "<storageAccountResourceId>"
    },
    "workspaceResourceId": {
      "value": "<workspaceResourceId>"
    }
  }
}
```

</details>
<p>


## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`location`](#parameter-location) | string | Location for all Resources. |
| [`name`](#parameter-name) | string | Name of the resource to create. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`addressPrefix`](#parameter-addressprefix) | string | The address prefix for the virtual network. |
| [`azureActivitiesSink`](#parameter-azureactivitiessink) | string | The resource ID of an auding function. |
| [`backendSecurityRules`](#parameter-backendsecurityrules) | array | Array of Security Rules to deploy to the Backend Network Security Group. When not provided, an NSG including only the default rules will be deployed. |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`eventHubAuthorizationRuleResourceId`](#parameter-eventhubauthorizationruleresourceid) | string | The event hub authorization rule resource ID. |
| [`eventHubName`](#parameter-eventhubname) | string | The event hub namespace name. |
| [`frontendSecurityRules`](#parameter-frontendsecurityrules) | array | Array of Security Rules to deploy to the Frontend Network Security Group. When not provided, an NSG including only the default rules will be deployed. |
| [`hubFirewallPrivateIp`](#parameter-hubfirewallprivateip) | string | The IP Address of the Hub Firewall. |
| [`lock`](#parameter-lock) | object | The lock settings of the service. |
| [`partnerCountry`](#parameter-partnercountry) | string | The Partner ID for partner attribution. |
| [`routes`](#parameter-routes) | array | An array of routes to be established within the hub route table. |
| [`storageAccountResourceId`](#parameter-storageaccountresourceid) | string | The storage account resource ID. |
| [`tags`](#parameter-tags) | object | Tags of the resource. |
| [`workspaceResourceId`](#parameter-workspaceresourceid) | string | The log analytics workspace resource ID. |

### Parameter: `location`

Location for all Resources.

- Required: Yes
- Type: string

### Parameter: `name`

Name of the resource to create.

- Required: Yes
- Type: string

### Parameter: `addressPrefix`

The address prefix for the virtual network.

- Required: No
- Type: string
- Default: `'10.0.0.0/24'`

### Parameter: `azureActivitiesSink`

The resource ID of an auding function.

- Required: No
- Type: string
- Default: `''`

### Parameter: `backendSecurityRules`

Array of Security Rules to deploy to the Backend Network Security Group. When not provided, an NSG including only the default rules will be deployed.

- Required: No
- Type: array
- Default: `[]`

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `eventHubAuthorizationRuleResourceId`

The event hub authorization rule resource ID.

- Required: No
- Type: string
- Default: `''`

### Parameter: `eventHubName`

The event hub namespace name.

- Required: No
- Type: string
- Default: `''`

### Parameter: `frontendSecurityRules`

Array of Security Rules to deploy to the Frontend Network Security Group. When not provided, an NSG including only the default rules will be deployed.

- Required: No
- Type: array
- Default: `[]`

### Parameter: `hubFirewallPrivateIp`

The IP Address of the Hub Firewall.

- Required: No
- Type: string
- Default: `'10.1.1.4'`

### Parameter: `lock`

The lock settings of the service.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`kind`](#parameter-lockkind) | string | Specify the type of lock. |
| [`name`](#parameter-lockname) | string | Specify the name of lock. |

### Parameter: `lock.kind`

Specify the type of lock.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'CanNotDelete'
    'None'
    'ReadOnly'
  ]
  ```

### Parameter: `lock.name`

Specify the name of lock.

- Required: No
- Type: string

### Parameter: `partnerCountry`

The Partner ID for partner attribution.

- Required: No
- Type: string
- Default: `'norway'`

### Parameter: `routes`

An array of routes to be established within the hub route table.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-routesname) | string | Name of the route. |
| [`properties`](#parameter-routesproperties) | object | Properties of the route. |

### Parameter: `routes.name`

Name of the route.

- Required: Yes
- Type: string

### Parameter: `routes.properties`

Properties of the route.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`nextHopType`](#parameter-routespropertiesnexthoptype) | string | The type of Azure hop the packet should be sent to. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`addressPrefix`](#parameter-routespropertiesaddressprefix) | string | The destination CIDR to which the route applies. |
| [`hasBgpOverride`](#parameter-routespropertieshasbgpoverride) | bool | A value indicating whether this route overrides overlapping BGP routes regardless of LPM. |
| [`nextHopIpAddress`](#parameter-routespropertiesnexthopipaddress) | string | The IP address packets should be forwarded to. Next hop values are only allowed in routes where the next hop type is VirtualAppliance. |

### Parameter: `routes.properties.nextHopType`

The type of Azure hop the packet should be sent to.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'Internet'
    'None'
    'VirtualAppliance'
    'VirtualNetworkGateway'
    'VnetLocal'
  ]
  ```

### Parameter: `routes.properties.addressPrefix`

The destination CIDR to which the route applies.

- Required: No
- Type: string

### Parameter: `routes.properties.hasBgpOverride`

A value indicating whether this route overrides overlapping BGP routes regardless of LPM.

- Required: No
- Type: bool

### Parameter: `routes.properties.nextHopIpAddress`

The IP address packets should be forwarded to. Next hop values are only allowed in routes where the next hop type is VirtualAppliance.

- Required: No
- Type: string

### Parameter: `storageAccountResourceId`

The storage account resource ID.

- Required: No
- Type: string
- Default: `''`

### Parameter: `tags`

Tags of the resource.

- Required: No
- Type: object

### Parameter: `workspaceResourceId`

The log analytics workspace resource ID.

- Required: No
- Type: string
- Default: `''`


## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `location` | string | The location the resource was deployed into. |
| `name` | string | The name of the virtual network. |
| `subnetNames` | array | The names of the deployed subnets. |
| `virtualNetworkResourceId` | string | The resource ID of the deployed virtual network. |

## Cross-referenced modules

This section gives you an overview of all local-referenced module files (i.e., other modules that are referenced in this module) and all remote-referenced files (i.e., Bicep modules that are referenced from a Bicep Registry or Template Specs).

| Reference | Type |
| :-- | :-- |
| `br/public:avm/ptn/security/security-center:0.1.0` | Remote reference |
| `br/public:avm/res/event-grid/system-topic:0.2.6` | Remote reference |
| `br/public:avm/res/network/network-security-group:0.1.3` | Remote reference |
| `br/public:avm/res/network/network-watcher:0.1.1` | Remote reference |
| `br/public:avm/res/network/route-table:0.2.2` | Remote reference |
| `br/public:avm/res/network/virtual-network:0.1.6` | Remote reference |
| `br/public:avm/res/storage/storage-account:0.9.0` | Remote reference |

## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the [repository](https://aka.ms/avm/telemetry). There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
