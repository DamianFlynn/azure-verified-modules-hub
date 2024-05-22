#region Helper functions

<#
.SYNOPSIS
Get modified files between previous and current commit depending on if you are running on main/master or a custom branch.

.EXAMPLE
Get-ModifiedFileList

    Directory: .avm\utilities\pipelines\publish

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
la---          08.12.2021    15:50           7133 Script.ps1

Get modified files between previous and current commit depending on if you are running on main/master or a custom branch.
#>
function Get-ModifiedFileList {

  # if ((Get-GitBranchName) -eq 'main') {
  Write-Verbose 'Gathering modified files from the previous head' -Verbose
  $Diff = git diff --name-only --diff-filter=AM HEAD^ HEAD
  # }
  $ModifiedFiles = $Diff ? ($Diff | Get-Item -Force) : @()

  return $ModifiedFiles
}

<#
.SYNOPSIS
Get the name of the current checked out branch.

.DESCRIPTION
Get the name of the current checked out branch. If git cannot find it, best effort based on environment variables is used.

.EXAMPLE
Get-CurrentBranch

Get the name of the current checked out branch.
#>
function Get-GitBranchName {
  [CmdletBinding()]
  param ()

  # Get branch name from Git
  $BranchName = git branch --show-current

  # If git could not get name, try GitHub variable
  if ([string]::IsNullOrEmpty($BranchName) -and (Test-Path env:GITHUB_REF_NAME)) {
    $BranchName = $env:GITHUB_REF_NAME
  }

  return $BranchName
}

<#
.SYNOPSIS
Find the closest main.json file to the changed files in the module folder structure.

.DESCRIPTION
Find the closest main.json file to the changed files in the module folder structure.

.PARAMETER ModuleFolderPath
Mandatory. Path to the main/parent module folder.

.EXAMPLE
Get-TemplateFileToPublish -ModuleFolderPath ".\avm\storage\storage-account\"

.\avm\storage\storage-account\table-service\table\main.json

Gets the closest main.json file to the changed files in the module folder structure.
Assuming there is a changed file in 'storage\storage-account\table-service\table'
the function would return the main.json file in the same folder.

#>
function Get-TemplateFileToPublish {

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string] $ModuleFolderPath,

    [Parameter(Mandatory)]
    [string[]] $PathsToInclude = @()
  )

  $ModuleRelativeFolderPath = ('avm/{0}' -f ($ModuleFolderPath -split '[\/|\\]avm[\/|\\]')[-1]) -replace '\\', '/'
  $ModifiedFiles = Get-ModifiedFileList -Verbose
  Write-Verbose "Looking for modified files under: [$ModuleRelativeFolderPath]" -Verbose
  $modifiedModuleFiles = $ModifiedFiles.FullName | Where-Object { $_ -like "*$ModuleFolderPath*" }

  $relevantPaths = @()
  $PathsToInclude += './version.json' # Add the file itself to be considered too
  foreach ($modifiedFile in $modifiedModuleFiles) {

    foreach ($path in  $PathsToInclude) {
      if ($modifiedFile -eq (Resolve-Path (Join-Path (Split-Path $modifiedFile) $path) -ErrorAction 'SilentlyContinue')) {
        $relevantPaths += $modifiedFile
      }
    }
  }

  $TemplateFilesToPublish = $relevantPaths | ForEach-Object {
    Find-TemplateFile -Path $_ -Verbose
  } | Sort-Object -Unique -Descending

  if ($TemplateFilesToPublish.Count -eq 0) {
    Write-Verbose 'No template file found in the modified module.' -Verbose
  }

  Write-Verbose ('Modified modules found: [{0}]' -f $TemplateFilesToPublish.count) -Verbose
  $TemplateFilesToPublish | ForEach-Object {
    $RelPath = ('avm/{0}' -f ($_ -split '[\/|\\]avm[\/|\\]')[-1]) -replace '\\', '/'
    $RelPath = $RelPath.Split('/main.')[0]
    Write-Verbose " - [$RelPath]" -Verbose
  }

  return $TemplateFilesToPublish
}

<#
.SYNOPSIS
Find the closest main.json file to the current directory/file.

.DESCRIPTION
This function will search the current directory and all parent directories for a main.json file.
This can be relevant if, for example, only a version.json file was changed, but what we need to find then is the corresponding main.json file.

.PARAMETER Path
Mandatory. Path to the folder/file that should be searched

.EXAMPLE
Find-TemplateFile -Path ".\avm\storage\storage-account\table-service\table\.bicep\nested_roleAssignments.bicep"

  Directory: .\avm\storage\storage-account\table-service\table

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
la---          05.12.2021    22:45           1230 main.json

Gets the closest main.json file to the current directory.
#>
function Find-TemplateFile {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string] $Path
  )

  $FolderPath = Split-Path $Path -Parent
  $FolderName = Split-Path $Path -Leaf
  if ($FolderName -eq 'modules') {
    return $null
  }

  #Prioritizing the bicep file
  $TemplateFilePath = Join-Path $FolderPath 'main.bicep'
  if (-not (Test-Path $TemplateFilePath)) {
    $TemplateFilePath = Join-Path $FolderPath 'main.json'
  }


  if (-not (Test-Path $TemplateFilePath)) {
    return Find-TemplateFile -Path $FolderPath
  }

  return ($TemplateFilePath | Get-Item).FullName
}
#endregion


<#
.SYNOPSIS
Gets the parent main.bicep/json file(s) to the changed files in the module folder structure.

.DESCRIPTION
Gets the parent main.bicep/json file(s) to the changed files in the module folder structure.

.PARAMETER TemplateFilePath
Mandatory. Path to a main.bicep/json file.

.PARAMETER Recurse
Optional. If true, the function will recurse up the folder structure to find the closest main.bicep/json file.

.EXAMPLE
Get-ParentModuleTemplateFile -TemplateFilePath 'C:\Repos\Azure\ResourceModules\modules\storage\storage-account\table-service\table\main.bicep' -Recurse

    Directory: C:\Repos\Azure\ResourceModules\modules\storage\storage-account\table-service

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
la---          05.12.2021    22:45           1427 main.bicep

    Directory: C:\Repos\Azure\ResourceModules\modules\storage\storage-account

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
la---          02.12.2021    13:19          10768 main.bicep

Gets the parent main.bicep/json file(s) to the changed files in the module folder structure.

#>
function Get-ParentModuleTemplateFile {

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string] $TemplateFilePath,

    [Parameter(Mandatory = $false)]
    [switch] $Recurse
  )

  $ModuleFolderPath = Split-Path $TemplateFilePath -Parent
  $ParentFolderPath = Split-Path $ModuleFolderPath -Parent

  #Prioritizing the bicep file
  $ParentTemplateFilePath = Join-Path $ParentFolderPath 'main.bicep'
  if (-not (Test-Path $TemplateFilePath)) {
    $ParentTemplateFilePath = Join-Path $ParentFolderPath 'main.json'
  }

  if (-not (Test-Path -Path $ParentTemplateFilePath)) {
    return
  }

  $ParentTemplateFilesToPublish = [System.Collections.ArrayList]@()
  $ParentTemplateFilesToPublish += $ParentTemplateFilePath | Get-Item

  if ($Recurse) {
    $ParentTemplateFilesToPublish += Get-ParentModuleTemplateFile $ParentTemplateFilePath -Recurse
  }

  return $ParentTemplateFilesToPublish
}

# end region

<#
.SYNOPSIS
Get the number of commits following the specified commit.

.PARAMETER Commit
Optional. A specified git reference to get commit counts on.

.EXAMPLE
Get-GitDistance -Commit origin/main.

620

There are currently 620 commits on origin/main. When run as a push on main, this will be the current commit number on the main branch.
#>
function Get-GitDistance {

  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $false)]
    [string] $Commit = 'HEAD'

  )

  return [int](git rev-list --count $Commit) + 1
}

# end region

<#
.SYNOPSIS
Gets the version from the version file from the corresponding main.bicep/json file.

.DESCRIPTION
Gets the version file from the corresponding main.bicep/json file.
The file needs to be in the same folder as the template file itself.

.PARAMETER TemplateFilePath
Mandatory. Path to a main.bicep/json file.

.EXAMPLE
Get-ModuleVersionFromFile -TemplateFilePath 'C:\Repos\Azure\ResourceModules\modules\storage\storage-account\table-service\table\main.bicep'

0.3

Get the version file from the specified main.bicep file.
#>
function Get-ModuleVersionFromFile {

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string] $TemplateFilePath
  )

  $ModuleFolder = Split-Path -Path $TemplateFilePath -Parent
  $VersionFilePath = Join-Path $ModuleFolder 'version.json'

  if (-not (Test-Path -Path $VersionFilePath)) {
    throw "No version file found at: [$VersionFilePath]"
  }

  $VersionFileContent = Get-Content $VersionFilePath | ConvertFrom-Json

  return $VersionFileContent.version
}

#end region

<#
.SYNOPSIS
Generates a new version for the specified module.

.DESCRIPTION
Generates a new version for the specified module, based on version.json file and git commit count.
Major and minor version numbers are gathered from the version.json file.
Patch version number is calculated based on the git commit count on the branch.

.PARAMETER TemplateFilePath
Mandatory. Path to a main.bicep/json file.

.EXAMPLE
Get-NewModuleVersion -TemplateFilePath 'C:\Repos\Azure\ResourceModules\modules\storage\storage-account\table-service\table\main.bicep'

0.3.630

Generates a new version for the table module.

#>
function Get-NewModuleVersion {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string] $TemplateFilePath
  )

  $Version = Get-ModuleVersionFromFile -TemplateFilePath $TemplateFilePath
  $Patch = Get-GitDistance
  $NewVersion = "$Version.$Patch"

  $BranchName = Get-GitBranchName -Verbose

  if ($BranchName -ne 'main' -and $BranchName -ne 'master') {
    $NewVersion = "$NewVersion-prerelease".ToLower()
  }

  return $NewVersion
}

#endregion

<#
.SYNOPSIS
Get any template (main.json) files in the given folder path that would qualify for publishing.

.DESCRIPTION
Get any template (main.json) files in the given folder path that would qualify for publishing.
Uses Head^-1 to check for changed files and filters them by the module path & path filter of the version.json

.PARAMETER ModuleFolderPath
Mandatory. The path to the module to check for changed files in.

.EXAMPLE
Get-ModulesToPublish -ModuleFolderPath "C:\avm\storage\storage-account"

Could return paths like
- C:\avm\storage\storage-account\main.json
- C:\avm\storage\storage-account\blob-service\main.json

#>
function Get-ModulesToPublish {


  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string] $ModuleFolderPath
  )

  $versionFile = (Get-Content (Join-Path $ModuleFolderPath 'version.json') -Raw) | ConvertFrom-Json
  $PathsToInclude = $versionFile.PathFilters

  # Check as per a `diff` with head^-1 if there was a change in any file that would justify a publish
  $TemplateFilesToPublish = Get-TemplateFileToPublish -ModuleFolderPath $ModuleFolderPath -PathsToInclude $PathsToInclude | Sort-Object FullName -Descending

  $modulesToPublish = [System.Collections.ArrayList]@()
  foreach ($TemplateFileToPublish in $TemplateFilesToPublish) {
    $ModuleVersion = Get-NewModuleVersion -TemplateFilePath $TemplateFileToPublish -Verbose

    $modulesToPublish += @{
      Version          = $ModuleVersion
      TemplateFilePath = $TemplateFileToPublish
    }

    if ($ModuleVersion -notmatch 'prerelease') {

      # Latest Major,Minor
      $modulesToPublish += @{
        Version          = ($ModuleVersion.Split('.')[0..1] -join '.')
        TemplateFilePath = $TemplateFileToPublish
      }

      # Latest Major
      $modulesToPublish += @{
        Version          = ($ModuleVersion.Split('.')[0])
        TemplateFilePath = $TemplateFileToPublish
      }

      if ($PublishLatest) {
        # Absolute latest
        $modulesToPublish += @{
          Version          = 'latest'
          TemplateFilePath = $TemplateFileToPublish
        }
      }
    }

    $ParentTemplateFilesToPublish = Get-ParentModuleTemplateFile -TemplateFilePath $TemplateFileToPublish -Recurse
    foreach ($ParentTemplateFileToPublish in $ParentTemplateFilesToPublish) {
      $ParentModuleVersion = Get-NewModuleVersion -TemplateFilePath $ParentTemplateFileToPublish.FullName

      $modulesToPublish += @{
        Version          = $ParentModuleVersion
        TemplateFilePath = $ParentTemplateFileToPublish
      }

      if ($ModuleVersion -notmatch 'prerelease') {

        # Latest Major,Minor
        $modulesToPublish += @{
          Version          = ($ParentModuleVersion.Split('.')[0..1] -join '.')
          TemplateFilePath = $ParentTemplateFileToPublish
        }

        # Latest Major
        $modulesToPublish += @{
          Version          = ($ParentModuleVersion.Split('.')[0])
          TemplateFilePath = $ParentTemplateFileToPublish
        }

        if ($PublishLatest) {
          # Absolute latest
          $modulesToPublish += @{
            Version          = 'latest'
            TemplateFilePath = $ParentTemplateFileToPublish
          }
        }
      }
    }
  }

  $modulesToPublish = $modulesToPublish | Sort-Object TemplateFilePath, Version -Descending -Unique

  if ($modulesToPublish.count -gt 0) {
    Write-Verbose 'Publish the following modules:'-Verbose
    $modulesToPublish | ForEach-Object {
      $RelPath = ($_.TemplateFilePath).Split('/avm/')[-1]
      $RelPath = $RelPath.Split('/main.')[0]
      Write-Verbose (' - [{0}] [{1}] ' -f $RelPath, $_.Version) -Verbose
    }
  } else {
    Write-Verbose 'No modules with changes found to publish.'-Verbose
  }




  # Filter out any children (as they're currently not considered for publishing)
  # $TemplateFilesToPublish = $TemplateFilesToPublish | Where-Object {
  #   # e.g., res\network\private-endpoint\main.json
  #   (($_ -split 'avm[\/|\\]')[1] -split '[\/|\\]').Count -le 4
  # }

  # Return the remaining template file(s)
  return $TemplateFilesToPublish
}
