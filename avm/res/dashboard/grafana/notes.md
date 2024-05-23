$TestModuleLocallyInput = @{
TemplateFilePath = './avm/res/dashboard/grafana/main.bicep'
ModuleTestFilePath = './avm/res/dashboard/grafana/tests/e2e/waf-aligned/main.test.bicep'

PesterTest = $true
ValidationTest = $true
WhatIfTest = $false
DeploymentTest = $true

ValidateOrDeployParameters = @{
Location = 'westeurope'
ResourceGroupName = 'cli-validation'
SubscriptionId = '7d443596-7c4e-477b-8213-12ef64c1858f'
ManagementGroupId = 'brightminds'
RemoveDeployment = $false
}

AdditionalTokens = @{
tenantId = 'd993d9e4-644e-4d0a-ba80-0e010d0ea023'
namePrefix = 'cli'
moduleVersion = '0.010'
}
}
