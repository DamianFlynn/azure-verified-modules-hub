# Azure Custom Resource Provider `[Microsoft.CustomProviders/resourceProviders]`

This module deploys an Azure Custom Resource Provider.

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
| `Microsoft.CustomProviders/resourceProviders` | [2018-09-01-preview](https://learn.microsoft.com/en-us/azure/templates/Microsoft.CustomProviders/2018-09-01-preview/resourceProviders) |

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

>**Note**: To reference the module, please use the following syntax `br/public:avm/res/custom-providers/resource-providers:<version>`.

- [Custom Function App Resource Provider](#example-1-custom-function-app-resource-provider)
- [Waf-Aligned](#example-2-waf-aligned)

### Example 1: _Custom Function App Resource Provider_

This instance deploys the module with the minimum set of required parameters.


<details>

<summary>via Bicep module</summary>

```bicep
module resourceProviders 'br/public:avm/res/custom-providers/resource-providers:<version>' = {
  name: 'resourceProvidersDeployment'
  params: {
    // Required parameters
    name: 'dbgmin001'
    // Non-required parameters
    actions: '<actions>'
    location: '<location>'
    resourceTypes: '<resourceTypes>'
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
      "value": "dbgmin001"
    },
    // Non-required parameters
    "actions": {
      "value": "<actions>"
    },
    "location": {
      "value": "<location>"
    },
    "resourceTypes": {
      "value": "<resourceTypes>"
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

### Example 2: _Waf-Aligned_

<details>

<summary>via Bicep module</summary>

```bicep
module resourceProviders 'br/public:avm/res/custom-providers/resource-providers:<version>' = {
  name: 'resourceProvidersDeployment'
  params: {
    // Required parameters
    name: 'cprpwaf001'
    // Non-required parameters
    location: '<location>'
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
      "value": "cprpwaf001"
    },
    // Non-required parameters
    "location": {
      "value": "<location>"
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
| [`name`](#parameter-name) | string | Name of your Azure Custom Provider. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`actions`](#parameter-actions) | array | Actions of the resource. |
| [`location`](#parameter-location) | string | Location for all Resources. |
| [`resourceTypes`](#parameter-resourcetypes) | array | Resource Types of the resource. |
| [`tags`](#parameter-tags) | object | Tags of the resource. |
| [`validations`](#parameter-validations) | array | Validations endpoints of the resource. |

### Parameter: `name`

Name of your Azure Custom Provider.

- Required: Yes
- Type: string

### Parameter: `actions`

Actions of the resource.

- Required: No
- Type: array
- Default: `[]`

### Parameter: `location`

Location for all Resources.

- Required: No
- Type: string
- Default: `[resourceGroup().location]`

### Parameter: `resourceTypes`

Resource Types of the resource.

- Required: No
- Type: array
- Default: `[]`

### Parameter: `tags`

Tags of the resource.

- Required: No
- Type: object

### Parameter: `validations`

Validations endpoints of the resource.

- Required: No
- Type: array
- Default: `[]`


## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The Name of the Azure Custom Provider. |
| `resourceGroupName` | string | The name of the Resource Group. |
| `resourceId` | string | The resource ID of the Azure Custom Provider. |

## Cross-referenced modules

_None_

## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the [repository](https://aka.ms/avm/telemetry). There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
