## Notes

To test the end-to-end functionality of the AVM, we have a set of tests that can be run. These tests are located in the `avm/ptn/lz/spoke/tests/e2e` directory. The tests are written in Python and use the `unittest` framework. The tests are run using the `unittest` test runner.

```powershell
$TestModuleLocallyInput = @{
  TemplateFilePath     = './avm/ptn/lz/spoke/main.bicep'
  ModuleTestFilePath   = './avm/ptn/lz/spoke/tests/e2e/waf-aligned/main.test.bicep'

  PesterTest           = $true
  DeploymentTest       = $true
  ValidationTest       = $true
  WhatIfTest           = $true

  ValidateOrDeployParameters = @{
    Location          = 'westeurope'
    ResourceGroupName = 'local-validation-rg'
    SubscriptionId    = '7d443596-7c4e-477b-8213-12ef64c1858f'
    ManagementGroupId = 'brightminds'
    RemoveDeployment  = $false
  }

  AdditionalTokens  = @{
    tenantId          = 'd993d9e4-644e-4d0a-ba80-0e010d0ea023'
    namePrefix        = 'cli'
    moduleVersion     = '0.010'
  }
}
```

then run the tests:

```powershell
Test-ModuleLocally @TestModuleLocallyInput -Verbose
```
