<#
    .SYNOPSIS
    This function creates a new feature branch and updates a workflow file based on the provided module type and name.

    .DESCRIPTION
    This function creates a new git branch with the name "feature/<ModuleName>". It then copies a template workflow file and replaces parts of it with the provided module name.

    .PARAMETER ModuleType
    The type of the module. It can be either 'ptn' or 'res'.

    .PARAMETER ModuleName
    The name of the module. It must be in the format 'domain.service'.
    #>

function New-FeatureBranch {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('ptn', 'res')]
        [string]$ModuleType,

        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[\w]+\.[\w]+$')]
        [string]$ModuleName
    )


    # Check if the branch exists
    $branchName = "feature/$ModuleType.$ModuleName"
    $branchExists = git rev-parse --verify $branchName 2>$null

    # If the branch doesn't exist, create it
    if ($null -eq $branchExists) {
        git checkout -b $branchName
        Write-Verbose "Switching to new branch '$outputPath'"
    } else {
        git checkout $branchName
        Write-Verbose "Switching to branch '$outputPath'"
    }


    # Define the template and output file paths
    $templatePath = './.github/workflows/avm.template.workflow.yml.starter'
    $outputPath = "./.github/workflows/avm.${ModuleType}.${ModuleName}.yml"

    # Copy the template to the new file
    if (-not (Test-Path $outputPath)) {
        Copy-Item $templatePath $outputPath
        Write-Verbose "Workflow File created at '$outputPath'"
    } else {
        Write-Verbose "Workflow File already exists at '$outputPath'"
    }

    # Replace the necessary parts in the new file
    Write-Verbose '- Configuring the Workflow'
    $slashModuleName = $ModuleName -replace '\.', '/'
    (Get-Content $outputPath) -replace 'res\.app\.job', "$ModuleType.$ModuleName" | Set-Content $outputPath
    (Get-Content $outputPath) -replace 'res/app/job', "$ModuleType/$slashModuleName" | Set-Content $outputPath

    # # Replace the Wofklow name, and file name in the file with the correct name - avm.res.app.job
    # $escapedModuleName = $ModuleName -replace '\.', '\\.'
    # (Get-Content $outputPath) -replace 'avm\\.res\\.app\\.job', "avm\\.$escapedModuleName" | Set-Content $outputPath

    # $slashEscapedModuleName = $ModuleName -replace '\.', '/' -replace '/', '\\/'
    # (Get-Content $outputPath) -replace 'avm\\/res\\/app\\/job', "avm\\/$slashEscapedModuleName" | Set-Content $outputPath



    Write-Verbose 'Configuring CODEOWNERS'
    # Define the path to the CODEOWNERS file
    $codeownersPath = './.github/CODEOWNERS'

    # Create the new module path and owner
    $modulePath = "/avm/$ModuleType/" + ($ModuleName -replace '\.', '/')
    $moduleOwner = '@Azure/avm-' + ($ModuleType + '-' + ($ModuleName -replace '-', '') -replace '\.', '-').ToLower() + '-module-owners-bicep'
    $globalOwner = '@Azure/avm-core-team-technical-bicep'

    # Read the CODEOWNERS file into an array
    $codeowners = Get-Content $codeownersPath

    # Add the new entry to the array
    $codeowners += "$modulePath $moduleOwner $globalOwner"
    $codeowners = $codeowners | Sort-Object { $_.Split(' ')[0] }
    $codeowners | Set-Content $codeownersPath


    # Define the path to the issue template file
    $issueTemplatePath = './.github/ISSUE_TEMPLATE/avm_module_issue.yml'

    # Create the new module path
    $modulePath = "/avm/$ModuleType/" + ($ModuleName -replace '\.', '/')

    # Load the issue template file as a PowerShell object
    # $issueTemplate = ConvertFrom-Json (Get-Content $issueTemplatePath -Raw)

    # # Find the dropdown with id 'module-name-dropdown' and add the new module path to its options
    # $dropdown = $issueTemplate.body | Where-Object { $_.id -eq 'module-name-dropdown' }
    # $dropdown.attributes.options += $modulePath

    # # Sort the options
    # $dropdown.attributes.options = $dropdown.attributes.options | Sort-Object

    # # Convert the PowerShell object back to JSON and write it back to the file
    # $issueTemplate | ConvertTo-Json -Depth 100 | Set-Content $issueTemplatePath

}
