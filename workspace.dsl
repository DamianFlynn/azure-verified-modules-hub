// workspace extends https://docs.structurizr.com/dsl/cookbook/workspace-extension/system-landscape.dsl {
// workspace extends ./system-landscape.dsl {
workspace  {
  name "Azure Verified Solutions"
  description "Automation Framework for Azure Module Validation and Publishing"

  !docs docs/system/
  !adrs docs/adrs

  model {

    contributor = person "Contributor" "Solution Engineer"
    engineer = person "User" "Platform Engineer"

    azureContainerRegistry = softwareSystem "Azure Container Registry" "Azure Container Registry" "External" {
      description "Azure Container Registry is a managed, private Docker registry service based on the open-source Docker Registry 2.0. Create and maintain Azure container registries to store and manage your private Docker container images and related artifacts."

      acrRepo = container "ACR Repository" "ACR Repository" "Bicep" "Browser,Microsoft Azure - Static Apps,Github"
    }

    privateTemplateSpecs = softwareSystem "Private Template Specs" "Private Template Specs" "Azure Artifacts" {
      privateTemplateSpecsRepo = container "Private Template Specs Repo" "Private Template Specs Repo" "Bicep" "Browser,Microsoft Azure - Static Apps,Github"
    }


    avsSystem = softwareSystem "Azure Verified Solutions" "Bicep Module Registry and Specs Hosted on  Github" "Github"{
      avsRepo = container "Azure-Verified-Solutions Repository" "IaC and Tooling" "Bicep" "Browser,Microsoft Azure - Static Apps,Github"

      workflowCheckLabelsWorkflow = container ".Platform - Check Labels" "Configure System Labels refelect coded standards" "GH Action" "Browser,Github - Action,Github" {
        properties {
          labels "Awaiting Module Path Assignment, Awaiting MCR Manifest Onboarding"
          file "platform.on-pull-request-check-labels.yml"
        }
      }


      workflowModulePublisher = container "Resource and Pattern Validation" "Lifecyle Per Module Trigger" "Browser,Github - Action,Github" {
        properties {
          file "avm.res|ptn.scope.name.yml"
        }
        getModuleTests = component "get-module-tests" "Get all e2e module test" "Action"
        initiateTestsValidatePublish = component "initiate-tests-validate-publish" "Prepare lifecycle check" "Action"
        getModuleTests -> initiateTestsValidatePublish "Calls"
      }


      workflowAVMTemplateModule = container "AVM Module Lifecycle" "Module Lifecycle Flow (Test, Validate and Publish)" "Browser,Github - Action,Github" {
        properties {
          file "./.github/workflows/avm.template.module.yml"
        }
        testModule = component "test-module" "Test Module" "Action"
        validateModule = component "validate-module" "Validate Module" "Action"
        publishModule = component "publish-module" "Publish Module" "Action"
        testModule -> validateModule "Calls"
        validateModule -> publishModule "Calls"
      }

      initiateTestsValidatePublish -> workflowAVMTemplateModule "calls"
      publishModule -> azureContainerRegistry "Publishs artifact to" "HTTPS"
      publishModule -> privateTemplateSpecs "Publishs to" "HTTPS"

      avsRepo -> workflowCheckLabelsWorkflow "On PR opened, labeled, synchronize"
      avsRepo -> workflowModulePublisher "On Schedule, PR Merge, Dispatch Event"
    }

    contributor -> avsSystem "to"
    engineer -> azureContainerRegistry "Uses"
    engineer -> privateTemplateSpecs "Uses"

    // !extend a {
    //   webapp = container "Web Application"
    //   database = container "Database"
    //   webapp -> b "Gets data X from"
    //   webapp -> database "Reads from and writes to"
    // }
  }


  views {
    systemContext avsSystem "SystemContext" {
      include *
      autoLayout
    }

    container avsSystem "Container" {
      include *
      autoLayout
    }

    component workflowModulePublisher "PublishModule" {
      include *
      autoLayout
    }

    component workflowAVMTemplateModule "TestValidatePublish" {
      include *
      autoLayout
    }

    // systemContext a "A-SystemContext" {
    //   include *
    //   autolayout lr
    // }
    // container a "A-Containers" {
    //   include *
    //   autolayout
    // }

    styles {
      element "Software System" {
        background #1168bd
        color #ffffff
      }
      element "Person" {
        shape person
        background #08427b
        color #ffffff
      }
    }
  }
}