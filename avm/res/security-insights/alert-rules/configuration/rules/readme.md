# Get Out of the Box Alert Rules

This PowerShell script processes a collection of analytic rule templates (presumably retrieved from an API or a similar data source) and performs several operations on each template:

1. **Converts the Collection to JSON and Back:** It starts by converting the collection of templates ($verdict.value) to JSON with a depth of 10, then converts it back from JSON. This process serves to ensure the data is in a clean, standardized format or to navigate through nested objects easily.

2. **Processes Each Template Individually:** For each template in the collection, the script performs a series of operations:

    * **Replaces Illegal Characters in Display Names:** It checks the display name of the template for the presence of the '/' character. If found, this character is replaced with ' or ', presumably to avoid file path issues when saving the template as a file. There's a minor bug in the script where the variable $displayname is not consistently cased, which could lead to unexpected behavior.

    * **Adds Missing Properties:** It adds several properties to the template that are presumably required for further processing but are not included in the original data. These properties are suppressionDuration, suppressionEnabled, enabled, alertRuleTemplateName, and templateVersion. The values for these properties are hardcoded or derived from the template's existing properties.

3. **Saves the Modified Templates to Files:** Based on the kind property of each template, the script saves the modified template to a JSON file in a specific subdirectory (`ml`, `scheduled`, `ti`, `microsoft-security`, `fusion`, `nrt`). If the template's kind does not match any of the specified categories, it is saved to a JSON file in the current directory. The file's name is derived from the template's display name, and the content is the entire template object converted to JSON with a depth of 10. The `-Force` parameter is used with `Out-File` to overwrite existing files without prompting.

Overall, this script is designed to preprocess and organize a set of analytic rule templates into a structured file system layout, making them ready for further use or deployment.

## Script Usage

```powershell
./get-ootb-analytic-rules.ps1 -resourceGroupName dep-avm-securityinsights-alertrules-csocmin-rg -workspaceName dep-avm-law-csocmin
```

