# Security Insights - Alert Rules `[Microsoft.SecurityInsights/alertRules]`

This Bicep module streamlines the configuration of Azure Sentinel by encompassing critical functionalities such as resource locking, Sentinel solution deployment, and alert rule setup within a Sentinel workspace. Key components include sentinel_lock for resource protection, sentinelWorkspace for existing workspace referencing, sentinel for solution deployment, and scheduledAlertRules for dynamic alert rule deployment. Tailored for flexibility, it adapts to input parameters to conditionally deploy resources, ensuring efficient setup and management of Azure Sentinel environments.

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
| `Microsoft.OperationsManagement/solutions` | [2015-11-01-preview](https://learn.microsoft.com/en-us/azure/templates/Microsoft.OperationsManagement/2015-11-01-preview/solutions) |
| `Microsoft.SecurityInsights/alertRules` | [2023-02-01-preview](https://learn.microsoft.com/en-us/azure/templates/Microsoft.SecurityInsights/2023-02-01-preview/alertRules) |

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

>**Note**: To reference the module, please use the following syntax `br/public:avm/res/security-insights/alert-rules:<version>`.

- [Security Insights - Alert Rules Default Configuration](#example-1-security-insights---alert-rules-default-configuration)
- [Security Insights - Alert Rules Well Architected Configuration](#example-2-security-insights---alert-rules-well-architected-configuration)

### Example 1: _Security Insights - Alert Rules Default Configuration_

This sample Bicep file demonstrates how to utilize the alertRules module to deploy predefined alert rules to an Azure Sentinel workspace. The Bicep file dynamically loads alert rules from source JSON or YAML files using the loadJsonContent or loadYamlContent functions, respectively. Additionally, it allows for the inclusion of customer-specific rules or overrides via a secondary array. Both arrays are combined using the native Bicep union function before being passed to the module for application.


<details>

<summary>via Bicep module</summary>

```bicep
module alertRules 'br/public:avm/res/security-insights/alert-rules:<version>' = {
  name: 'alertRulesDeployment'
  params: {
    // Required parameters
    name: 'csocmin001'
    sentinelWorkspaceId: '<sentinelWorkspaceId>'
    // Non-required parameters
    location: '<location>'
    lock: {
      kind: 'None'
    }
    rules: '<rules>'
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
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
    "name": {
      "value": "csocmin001"
    },
    "sentinelWorkspaceId": {
      "value": "<sentinelWorkspaceId>"
    },
    // Non-required parameters
    "location": {
      "value": "<location>"
    },
    "lock": {
      "value": {
        "kind": "None"
      }
    },
    "rules": {
      "value": "<rules>"
    },
    "tags": {
      "value": {
        "Environment": "Non-Prod",
        "hidden-title": "This is visible in the resource name",
        "Role": "DeploymentValidation"
      }
    }
  }
}
```

</details>
<p>

### Example 2: _Security Insights - Alert Rules Well Architected Configuration_

This sample Bicep file demonstrates the deployment of Azure Sentinel alert rules using the AlertRules module. The Bicep file utilizes the alertRules array to dynamically load alert rules from their source JSON or YAML files during compile time, leveraging Biceps loadJsonContent or loadYamlContent functions. Moreover, the module is configured to implement the recommended Well Architected Features for efficient deployment and management of alert rules in an Azure Sentinel workspace.


<details>

<summary>via Bicep module</summary>

```bicep
module alertRules 'br/public:avm/res/security-insights/alert-rules:<version>' = {
  name: 'alertRulesDeployment'
  params: {
    // Required parameters
    name: 'csocwaf001'
    sentinelWorkspaceId: '<sentinelWorkspaceId>'
    // Non-required parameters
    location: '<location>'
    lock: {
      kind: 'None'
    }
    rules: '<rules>'
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
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
    "name": {
      "value": "csocwaf001"
    },
    "sentinelWorkspaceId": {
      "value": "<sentinelWorkspaceId>"
    },
    // Non-required parameters
    "location": {
      "value": "<location>"
    },
    "lock": {
      "value": {
        "kind": "None"
      }
    },
    "rules": {
      "value": "<rules>"
    },
    "tags": {
      "value": {
        "Environment": "Non-Prod",
        "hidden-title": "This is visible in the resource name",
        "Role": "DeploymentValidation"
      }
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
| [`name`](#parameter-name) | string | Name of the resource to create. |
| [`sentinelWorkspaceId`](#parameter-sentinelworkspaceid) | string | The workspace ID of the Sentinel workspace we will be working with. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`location`](#parameter-location) | string | Location for all Resources. |
| [`lock`](#parameter-lock) | object | The lock settings of the service. |
| [`rules`](#parameter-rules) | array | An array of alert rules to create. |
| [`tags`](#parameter-tags) | object | Tags of the storage account resource. |

### Parameter: `name`

Name of the resource to create.

- Required: Yes
- Type: string

### Parameter: `sentinelWorkspaceId`

The workspace ID of the Sentinel workspace we will be working with.

- Required: Yes
- Type: string

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `location`

Location for all Resources.

- Required: No
- Type: string
- Default: `[resourceGroup().location]`

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

### Parameter: `rules`

An array of alert rules to create.

- Required: No
- Type: array
- Default: `[]`

### Parameter: `tags`

Tags of the storage account resource.

- Required: No
- Type: object


## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `location` | string | The location the resource was deployed into. |
| `name` | string | The name of the resource. |
| `resourceGroupName` | string | The resource group of the resource. |
| `resourceId` | string | The resource ID of the resource. |

## Cross-referenced modules

_None_

## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the [repository](https://aka.ms/avm/telemetry). There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
