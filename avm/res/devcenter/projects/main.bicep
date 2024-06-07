@description('Required. The name of the DevCenter to create.')
param name string = 'InnofactorDevPlatform'

@description('Optional. The location to create the DevCenter. Default is the location of the resource group.')
param location string = resourceGroup().location

@description('Optional. The name of the project to create. Default is azure-verified-solutions.')
param projectName string = 'azure-verified-solutions'

resource devcenter 'Microsoft.DevCenter/devcenters@2024-05-01-preview' = {
  name: name
  location: location
  identity: {
    type: 'None'
  }
  properties: {}
}

resource catalog 'Microsoft.DevCenter/devcenters/catalogs@2024-05-01-preview' = {
  parent: devcenter
  name: 'quickstart-environment-definitions'
  properties: {
    gitHub: {
      uri: 'https://github.com/microsoft/devcenter-catalog.git'
      branch: 'main'
      path: 'Environment-Definitions'
    }
  }
}

resource environment 'Microsoft.DevCenter/devcenters/environmentTypes@2024-05-01-preview' = {
  parent: devcenter
  name: 'Sandbox'
  tags: {
    Environment: 'Sandbox'
  }
  properties: {
    displayName: 'Sandbox Environment'
  }
}

resource environmentRestricted 'Microsoft.DevCenter/devcenters/environmentTypes@2024-05-01-preview' = {
  parent: devcenter
  name: 'Restricted'
  tags: {
    Environment: 'Restricted'
  }
  properties: {
    displayName: 'Restricted Environment'
  }
}

// resource galleries 'Microsoft.DevCenter/devcenters/galleries@2024-05-01-preview' = {
//   parent: devcenter
//   name: 'Default'
//   properties: {
//     galleryResourceId: galleries.id
//   }
// }

resource project 'Microsoft.DevCenter/projects@2024-05-01-preview' = {
  name: projectName
  location: location
  tags: {
    'hidden-title': 'azure-verified-solutions'
  }
  properties: {
    devCenterId: devcenter.id
    description: 'Working Area for the engineering and validation of the patterns and solutions'
    maxDevBoxesPerUser: 1
    displayName: projectName
  }
}

resource projectEnvironmentRestricted 'Microsoft.DevCenter/projects/environmentTypes@2024-05-01-preview' = {
  parent: project
  name: 'Restricted'
  tags: {
    'Project Id': 'azure-verified-solutions'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    deploymentTargetId: '/subscriptions/ee6ff44d-b640-42e4-89fd-bc67c48d3764'
    status: 'Enabled'
    creatorRoleAssignment: {
      roles: {
        'b24988ac-6180-42a0-ab88-20f7382dd24c': {}
      }
    }
  }
}

resource projectEnvironment 'Microsoft.DevCenter/projects/environmentTypes@2024-05-01-preview' = {
  parent: project
  name: 'Sandbox'
  tags: {
    'Project Id': 'azure-verified-solutions'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    deploymentTargetId: '/subscriptions/be4ed894-df20-42f3-8a1d-24934ea8f725'
    status: 'Enabled'
    creatorRoleAssignment: {
      roles: {
        'b24988ac-6180-42a0-ab88-20f7382dd24c': {}
      }
    }
  }
}
