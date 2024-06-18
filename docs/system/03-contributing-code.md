## Contributing Code

Now that you have cloned the repository locally on your computer, it's time to contribute code. Direct changes to the main branch are restricted to ensure the integrity of the repository. Instead, contributions should be made through a structured process involving issues and pull requests.

Before adding any code, we must create an issue in the repository. This step ensures that the contribution is valid and not already being addressed by someone else. The person responsible for the issue, referred to as the CODEOWNER, will oversee the issue until it is resolved.

A typical issue will include the following information:

- Issue number
- Title
- User Story
- Acceptance Criteria
- Module Name

### Creating an Issue

1. Navigate to the repository on GitHub.
2. Click on the Issues tab.
3. Click on the New Issue button.
4. Select the Template for the type of issue you are creating (Module Issue, General Question/Feedback, New Module, etc.).
5. Fill in the required information.
6. Click on the Submit new issue button.

The assigned person will be responsible for the issue until it is resolved.

### Creating a branch in Visual Studio Code

1. Open Visual Studio Code.
1. Open the source control panel by clicking on the source control icon in the sidebar or by using the shortcut `Ctrl+Shift+G`.
1. Create a branch from the `main` branch:
   1. Click on the branch name in the bottom-left corner of the status bar.
   1. Select **Create new branch** from the menu.
   1. Name your branch using your GitHub username followed by the issue number. For example, `username/issue1436`.

### Tool Chain

Before creating a module, ensure you have the necessary utilities registered in your **PowerShell** session. Navigate to the root directory of your repository. In this example, we use `~/Developer/InnofactorOrg/Azure-Verified-Solutions`. Once there, dot source both tools:

```powershell
# Dot Source the Utilities
. ./avm/utilities/tools/Set-AVMModule.ps1
. ./avm/utilities/tools/Test-ModuleLocally.ps1
```

The `Set-AVMModule` utility automates the generation of content for modules, while `Test-ModuleLocally` validates the module's functionality.

#### Set-AVMModule Utility

The `Set-AVMModule` utility streamlines several housekeeping tasks when working with Azure Verified Modules. For new modules, it accelerates the setup process by creating the necessary scaffolding using templates. For existing modules, it regenerates the ARM template from the Bicep file, updates the `README.md` file, and alerts you to potential issues or warnings.

As we are initiating a new module, it must reside within the `./avm/` directory. For this guide, we will focus on creating a module to deploy an **Azure Grafana Dashboard**:

```powershell
# Create the module folder
mkdir -p ./avm/res/dashboard/grafana
```

Next, establish the AVM structure within this folder manually or by using `Set-AVMModule`:

```powershell
Set-AVMModule -ModuleFolderPath ./avm/res/dashboard/grafana
```

This command generates the following structure within our repository, starting at the module folder:

```yaml
📁 avm                                # Module root
└─📁 res/dashboard/grafana            # Module namespace and name
  ├─📁 tests                          # Unit tests for validating the module
  │ └─📁 e2e                          # End-to-End tests
  │   ├─📁 defaults                   # Default test scenario
  │   │ └─📁 main.test.bicep          # Main bicep file referencing the module
  │   └─📁 waf-aligned                # WAF aligned test scenario
  │     └─📁 main.test.bicep          # Main bicep file referencing the module
  ├─📁 docs                           # Documentation for the module
  │ ├─📁 system                       # System documentation
  │ │ └─📁 00-index.md                # Main index for system documentation
  │ └─📁 adrs                         # Architecture Design Records
  │     └─📁 0001-adr.md              # Each design decision, in numerical order
  ├─📁 main.bicep                     # Main bicep file for the module
  ├─📁 main.json                      # ARM template generated from main.bicep
  ├─📁 README.md                      # README file generated using Set-AVMModule
  ├─📁 workspace.dsl                  # Structurizr Architecture Definition
  └─📁 version.json                   # Version file for the module
```

#### Module Functionality

The `main.bicep` file serves as the primary orchestrator for the module's infrastructure. The `e2e` folder contains operational tests, with subfolders `defaults` and `waf-aligned` catering to different testing scenarios.

Additional testing scenarios can be added by introducing new folders and `main.test.bicep` files within the `e2e` directory. The utility will automatically detect these additions.

Subsequent calls to `Set-AVMModule` will conduct various checks before regenerating the ARM template `main.json` from `main.bicep`. It will also create or update the `README.md` file, providing context and alerts for any potential issues or warnings.

```powershell
Set-AVMModule -ModuleFolderPath ./avm/res/dashboard/grafana
```

This command will build the module, generate the README, and alert you to any potential issues or warnings, ensuring a robust and well-documented module ready for deployment.

We are now ready to being the implementation of the module.
