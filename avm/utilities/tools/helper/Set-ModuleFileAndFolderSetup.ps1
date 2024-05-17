<#
.SYNOPSIS
Idempotently set an initial file and folder structure for an intended module path

.DESCRIPTION
Idempotently set an initial file and folder structure for an intended module path. Will setup the path if it does not exist yet.
Most files will contain an initial set of content.
Note: The ReadMe & main.json file(s) will not be generated by this script.

.PARAMETER FullModuleFolderPath
Mandatory. The full module path to create.

.PARAMETER CurrentLevelFolderPath
Optional. The level the current invocation is at. Used for recursion. Do not provide.

.EXAMPLE
Set-ModuleFileAndFolderSetup -FullModuleFolderPath '<repoPath>\avm\res\storage\storage-account\blob-service\container'

Results into:
- Added file [<repoPath>\avm\res\storage\storage-account\main.bicep]
- Added file [<repoPath>\avm\res\storage\storage-account\version.json]
- Added file [<repoPath>\avm\res\storage\storage-account\tests\e2e\defaults\main.test.bicep]
- Added file [<repoPath>\avm\res\storage\storage-account\tests\e2e\waf-aligned\main.test.bicep]
- Added file [<repoPath>\avm\res\storage\storage-account\blob-service\main.bicep]
- Added file [<repoPath>\avm\res\storage\storage-account\blob-service\container\main.bicep]

.EXAMPLE
Set-ModuleFileAndFolderSetup -FullModuleFolderPath '<repoPath>\avm\res\storage\storage-account'

Results into:
- Added file [<repoPath>\avm\res\storage\storage-account\main.bicep]
- Added file [<repoPath>\avm\res\storage\storage-account\version.json]
- Added file [<repoPath>\avm\res\storage\storage-account\tests\e2e\defaults\main.test.bicep]
- Added file [<repoPath>\avm\res\storage\storage-account\tests\e2e\waf-aligned\main.test.bicep]

#>
function Set-ModuleFileAndFolderSetup {

    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [string] $FullModuleFolderPath,

        [Parameter(Mandatory = $false)]
        [string] $CurrentLevelFolderPath
    )

    if ([String]::IsNullOrEmpty($CurrentLevelFolderPath)) {
        # First invocation. Handling provider namespace
        $resourceTypeIdentifier = ($FullModuleFolderPath -split '[\/|\\]{1}avm[\/|\\]{1}(res|ptn)[\/|\\]{1}')[2] # avm/res/<provider>/<resourceType>
        $providerNamespace, $resourceType, $childResourceType = $resourceTypeIdentifier -split '[\/|\\]', 3
        $avmModuleRoot = ($FullModuleFolderPath -split $providerNamespace)[0]
        $currentLevelFolderPath = Join-Path $avmModuleRoot $providerNamespace $resourceType
    }

    # Collect data
    $resourceTypeIdentifier = ($CurrentLevelFolderPath -split '[\/|\\]{1}avm[\/|\\]{1}(res|ptn)[\/|\\]{1}')[2] # avm/res/<provider>/<resourceType>
    $isTopLevel = ($resourceTypeIdentifier -split '[\/|\\]').Count -eq 2

    # Mandatory files
    # ===============

    # Template file
    # -------------
    $bicepFilePath = Join-Path $CurrentLevelFolderPath 'main.bicep'
    if (-not (Test-Path $bicepFilePath)) {
        if ($PSCmdlet.ShouldProcess("File [$bicepFilePath]", 'Add')) {
            $null = New-Item -Path $bicepFilePath -ItemType 'File' -Force
        }

        $defaultTemplateSourceFilePath = Join-Path $PSScriptRoot 'src' ($isTopLevel ? 'src.main.bicep' : 'src.child.main.bicep')
        if (Test-Path $defaultTemplateSourceFilePath) {
            $defaultTemplateSourceFileContent = Get-Content -Path $defaultTemplateSourceFilePath
            if ($PSCmdlet.ShouldProcess("content for file [$bicepFilePath]", 'Set')) {
                $null = Set-Content -Path $bicepFilePath -Value $defaultTemplateSourceFileContent
            }
        }
        Write-Verbose "Added file [$bicepFilePath]" -Verbose
    }

    # README can be generated by parent script
    # main.json can be generated by parent script

    # Top-level-only files
    # ====================
    if ($isTopLevel) {
        # Version file
        # ------------
        $versionFilePath = Join-Path $CurrentLevelFolderPath 'version.json'
        if (-not (Test-Path $versionFilePath)) {
            if ($PSCmdlet.ShouldProcess("File [$versionFilePath]", 'Add')) {
                $null = New-Item -Path $versionFilePath -ItemType 'File' -Force
            }

            $versionSourceFilePath = Join-Path $PSScriptRoot 'src' 'src.version.json'
            if (Test-Path $versionSourceFilePath) {
                $versionSourceFileContent = Get-Content -Path $versionSourceFilePath
                if ($PSCmdlet.ShouldProcess("content for file [$versionFilePath]", 'Set')) {
                    $null = Set-Content -Path $versionFilePath -Value $versionSourceFileContent
                }
            }
            Write-Verbose "Added file [$versionFilePath]" -Verbose
        }

        # Defaults test file
        # -----------------
        $testCasesPath = Join-Path $CurrentLevelFolderPath 'tests' 'e2e'
        $currentTestFolders = Get-ChildItem -Path $testCasesPath -Directory | ForEach-Object { $_.Name }

        if (($currentTestFolders -match '.*defaults').count -eq 0) {
            $defaultTestFilePath = Join-Path $testCasesPath 'defaults' 'main.test.bicep'
            if ($PSCmdlet.ShouldProcess("file [$defaultTestFilePath]", 'Add')) {
                $null = New-Item -Path $defaultTestFilePath -ItemType 'File' -Force
            }
            $defaultTestTemplateSourceFilePath = Join-Path $PSScriptRoot 'src' 'src.main.test.bicep'
            if (Test-Path $defaultTestTemplateSourceFilePath) {
                $defaultTestTemplateSourceFileContent = Get-Content -Path $defaultTestTemplateSourceFilePath

                $suggestedServiceShort = '{0}def' -f (($resourceTypeIdentifier -split '[\/|\\|-]' | ForEach-Object { $_[0] }) -join '') # e.g., npemin
                $defaultTestTemplateSourceFileContent = $defaultTestTemplateSourceFileContent -replace '<serviceShort>', $suggestedServiceShort

                $suggestedResourceGroupName = $resourceTypeIdentifier -replace '[\/|\\]', '.' -replace '-' # e.g., network.privateendpoints
                $defaultTestTemplateSourceFileContent = $defaultTestTemplateSourceFileContent -replace '<The test resource group name>', $suggestedResourceGroupName

                if ($PSCmdlet.ShouldProcess("content for file [$defaultTestFilePath]", 'Set')) {

                    $null = Set-Content -Path $defaultTestFilePath -Value $defaultTestTemplateSourceFileContent
                }
            }

            Write-Verbose "Added file [$defaultTestFilePath]" -Verbose
        }

        # WAF-aligned test file
        # ---------------------
        if (($currentTestFolders -match '.*waf-aligned').count -eq 0) {
            $wafTestFilePath = Join-Path $testCasesPath 'waf-aligned' 'main.test.bicep'
            if ($PSCmdlet.ShouldProcess("file [$wafTestFilePath]", 'Add')) {
                $null = New-Item -Path $wafTestFilePath -ItemType 'File' -Force
            }

            $wafTestTemplateSourceFilePath = Join-Path $PSScriptRoot 'src' 'src.main.test.bicep'
            if (Test-Path $wafTestTemplateSourceFilePath) {
                $wafTestTemplateSourceFileContent = Get-Content -Path $wafTestTemplateSourceFilePath

                $suggestedServiceShort = '{0}waf' -f (($resourceTypeIdentifier -split '[\/|\\|-]' | ForEach-Object { $_[0] }) -join '') # e.g., npemin
                $wafTestTemplateSourceFileContent = $wafTestTemplateSourceFileContent -replace '<serviceShort>', $suggestedServiceShort

                $suggestedResourceGroupName = $resourceTypeIdentifier -replace '[\/|\\]', '.' -replace '-' # e.g., network.privateendpoints
                $wafTestTemplateSourceFileContent = $wafTestTemplateSourceFileContent -replace '<The test resource group name>', $suggestedResourceGroupName

                if ($PSCmdlet.ShouldProcess("content for file [$wafTestFilePath]", 'Set')) {
                    $null = Set-Content -Path $wafTestFilePath -Value $wafTestTemplateSourceFileContent
                }
            }
            Write-Verbose "Added file [$wafTestFilePath]" -Verbose
        }
    }

    # Check if there are nested modules to handle (recursion)
    if ($CurrentLevelFolderPath -ne $FullModuleFolderPath) {
        # More children to handle
        $nextChild = ($FullModuleFolderPath -replace ('{0}[\/|\\]*' -f [Regex]::Escape($CurrentLevelFolderPath)) -split '[\/|\\]')[0]
        Set-ModuleFileAndFolderSetup -FullModuleFolderPath $FullModuleFolderPath -CurrentLevelFolderPath (Join-Path $CurrentLevelFolderPath $nextChild)
    }
}