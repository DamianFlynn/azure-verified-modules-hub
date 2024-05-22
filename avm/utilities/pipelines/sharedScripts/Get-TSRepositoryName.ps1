<#
.SYNOPSIS
Convert the given template file path into a valid Template Spec repository name

.DESCRIPTION
Convert the given template file path into a valid Template Spec repository name

.PARAMETER TemplateFilePath
Mandatory. The template file path to convert

.EXAMPLE
Get-TSRepositoryName -TemplateFilePath 'C:\avm\res\key-vault\vault\main.bicep'

Convert 'C:\avm\res\key-vault\vault\main.bicep' to e.g. 'avm.res.key-vault.vault'
#>
function Get-TSRepositoryName {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $TemplateFilePath
    )

    $moduleIdentifier = (Split-Path $TemplateFilePath -Parent) -split '[\/|\\]avm[\/|\\](res|ptn)[\/|\\]'
    return ('avm.{0}.{1}' -f $moduleIdentifier[1], $moduleIdentifier[2]) -replace '\\', '.'
}

# end region


<#
.SYNOPSIS
   Extracts the metadata from a Bicep file.

.DESCRIPTION
   The Get-BicepFileMetadata function reads a Bicep file and extracts the metadata values for 'name', 'description', and 'owner'.
   It returns these values as a hashtable.

.PARAMETER TemplateFilePath
   The path to the Bicep file.

.EXAMPLE
   Get-BicepFileMetadata -TemplateFilePath "./template.bicep"

   This command extracts the metadata from the Bicep file at "./template.bicep".

.OUTPUTS
   Hashtable. This function returns a hashtable with keys 'name', 'description', and 'owner'.

.NOTES
   The Bicep file must contain metadata fields 'name', 'description', and 'owner' for this function to work correctly.
#>
function Get-BicepFileMetadata {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $TemplateFilePath
    )

    $content = Get-Content -Path $TemplateFilePath -Raw
    $name = $content | Select-String -Pattern "metadata name = '([^']*)'"
    $description = $content | Select-String -Pattern "metadata description = '([^']*)'"
    $owner = $content | Select-String -Pattern "metadata owner = '([^']*)'"

    $metadataObject = @{
        name        = $name.Matches.Groups[1].Value
        description = $description.Matches.Groups[1].Value
        owner       = $owner.Matches.Groups[1].Value
    }

    return $metadataObject
}

# end region
