// Landing Zone for Container Registry

workspace  {
  name "Container Registry"
  description "Landing Zone for Container Registry"

  !docs docs/system/
  !adrs docs/adrs

  model {

    // Software System for Azure Container Registry
    //
    azureContainerRegistry = softwareSystem "Azure Container Registry" "OCI Compliant Registry" "OCI Artifacts" {
      ociRepositories = container "Container Repository" "Registry Hosted Repositories" "OCI Repository" "Browser,Microsoft Azure - Static Apps,Github"
      ociArtifacts = container "OCI Artifacts" "OCI Artifact" "OCI" "Browser"

      ociRepositories -> ociArtifacts "Hosts"
    }

    // Reference Instance for Azure Container Registry Deployment
    //

    acrReferenceInstance = deploymentEnvironment "Azure Container Registry Instance" {
      deploymentNode "Azure Workloads" {
        tags "Microsoft Azure - Management Groups"

        acrLandingZoneSub = deploymentNode "ACR Landing Zone Subscription" {
          tags "Microsoft Azure - Subscriptions"

          acrWorkloadRg = deploymentNode "ACR Resource Group" {
            tags "Microsoft Azure - Resource Groups"

            acrResource = deploymentNode "Container Registry" {
              tags "Microsoft Azure - Azure Container Registry"

              acrOciRepositories = containerInstance ociRepositories
              deploymentNode "Repository" {
                tags "Microsoft Azure - App Services"

                ociArtifactsInstances = containerInstance ociArtifacts
              }
            }
          }
        }
      }
    }
  }

  views {
    systemContext azureContainerRegistry "ACR-SystemContext" {
      include *
      autolayout lr
    }
    container azureContainerRegistry "ACR-Containers" {
      include *
      autolayout
    }
    deployment azureContainerRegistry  "acrReferenceInstance"  "acrReferenceInstance" {
      include *
      autoLayout
    }

    themes default "https://static.structurizr.com/themes/microsoft-azure-2023.01.24/theme.json"
    styles {
      element "Azure" {
        color #ffffff
      }
      element "External" {
        background #783aba
        color #ffffff
      }
      element "Database" {
        shape Cylinder
      }
      element "Browser" {
        shape WebBrowser
      }
    }
  }

}