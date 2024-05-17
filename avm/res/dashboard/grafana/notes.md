$TestModuleLocallyInput = @{
  TemplateFilePath     = './avm/res/dashboard/grafana/main.bicep'
  ModuleTestFilePath   = './avm/res/dashboard/grafana/tests/e2e/waf-aligned/main.test.bicep'

  PesterTest           = $true
  ValidationTest       = $false
  WhatIfTest           = $false
  DeploymentTest       = $false

  ValidateOrDeployParameters = @{
    Location          = 'westeurope'
    ResourceGroupName = 'local-validation-rg'
    SubscriptionId    = 'a39403bb-a54d-4edf-a44e-83a4249d0f4a'
    ManagementGroupId = 'workloads'
    RemoveDeployment  = $false
  }

  AdditionalTokens  = @{
    tenantId          = '67481c72-d897-4db4-a7fa-b96d76dfb545'
    namePrefix        = 'avm'
    moduleVersion     = '0.010'
  }
}