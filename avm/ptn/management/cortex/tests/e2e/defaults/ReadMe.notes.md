# Deployment Notes for Test: defaults

THis is a subscription level deployment.  The deployment will create a resource group and a storage account.  The storage account will be created with the default values.

```powershell
New-AzSubscriptionDeployment -Location WestEurope  -TemplateFile ./main.test.bicep
```

## Function Application

### Update the Application Package

Using Visual Studio Code:

* Open your .NET 8 isolated application project in Visual Studio Code.
* Use the integrated terminal in VS Code to navigate to the root folder of your project.
* Run the `dotnet publish -o OutputDirectory` command to publish the project files.
* ```powershell
  dotnet publish . --configuration Release -o Arfifacts --self-contained false
  ```
* Utilize the integrated terminal to run the `Compress-Archive` command to zip the published folder.
* ```powershell
  # We MUST include the .azurefunctions folder, so Get-ChildItem -Force is used to include hidden files
  Get-ChildItem -Path ./Arfifacts/ -Force | Compress-Archive -DestinationPath .\functionApp.zip -Force
  rm -r .\Arfifacts
  ```

By following these steps, you can create a zipped package for your .NET 8 isolated application that is ready to be deployed to an Azure Function using the WEBSITE_RUN_FROM_PACKAGE application setting.

### Manual Deployment
The sample function application is located in the `functionApp` folder, and should be deployed before the custom resources can be utilized.

Open VS Code, and select to open the folder `/avm/res/custom-providers/resource-providers/functionApp'

Using the control Pallet, select `Azure Functions: Deploy to Function App...`
Select the new function app created by the deployment, `dep-custrp-fn-dbgmin`
When prompted if you are sure, select `Deploy`
