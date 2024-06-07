# Deployment Steps

using the following AZ commands, we will first select the subscription and then create a resource group.

```sh
az account set --subscription c868a8cf-253e-4ca2-9595-a539cf17f678
az group create --name "p-devcenter" --location "westeurope"
```

Next, we will deploy the Bicep file to the resource group.

```sh
az deployment group create --resource-group "p-devcenter" --template-file main.bicep
```
