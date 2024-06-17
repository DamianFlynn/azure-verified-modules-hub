// Function Application that runs its logic from a container
// --> Retrieves its containers from and Instance of System B

workspace extends ../../lz/container-registry/workspace.dsl {
  name "Function Application"
  description "Landing Zone for Function Application"

  !docs docs/system/
  !adrs docs/adrs

  model {

    // Software System for Azure Function Application
    //

    azureFunctionApp = softwareSystem "Azure Function Application" "Azure Function Application Instance" {

      appPlan = container "AppService Plan" "Azure App Service Plan" "Microsoft Azure - App Service Plans"
      apiContainer = container "API" "Backend" "ASP.NET Core" "Microsoft Azure - App Services,Azure" {
        group "API Service" {
          controllerComp = component "API Controller" "Requests, responses, routing and serialization" "ASP.NET Core"
        }
      }
      appPlan -> apiContainer "Hosts"
      apiContainer -> azureContainerRegistry "Retrieves container image from"
    }

    // Reference Instance for Azure Function Application Deployment
    //
    azFuncReferenceInstance = deploymentEnvironment "Azure FunctionApp Instance" {
      deploymentNode "Azure Workloads" {
        tags "Microsoft Azure - Management Groups"

        dnsSub = deploymentNode "Public DNS Subscription" {
          tags "Microsoft Azure - Subscriptions"

          dnsRg = deploymentNode "DNS Resource Group" {
            tags "Microsoft Azure - Resource Groups"

            publicDns = infrastructureNode "DNS Zones" {
              description "Highly available and scalable cloud DNS service."
              tags "Microsoft Azure - DNS Zones"
            }
          }
        }

        azFuncLandingZoneSub = deploymentNode "FunctionApp Landing Zone Subscription" {
          tags "Microsoft Azure - Subscriptions"

          azFuncNetworkRg = deploymentNode "FunctionApp Network Resource Group" {
            tags "Microsoft Azure - Resource Groups"

            azFuncVNetwork = infrastructureNode "Workload vNET" {
              description "Virtual Network for Web App Workload."
              tags "Microsoft Azure - Virtual Networks"
            }
          }

          azFuncWorkloadRg = deploymentNode "FunctionApp Resource Group" {
            tags "Microsoft Azure - Resource Groups"

            azWebAppPlan = deploymentNode "AppService Plan" {
              tags "Microsoft Azure - App Service Plans"

              deploymentNode "Web App" {
                tags "Microsoft Azure - App Services"

                webApplicationInstance = containerInstance appPlan
              }
            }

            azFuncResource = deploymentNode "FunctionApp" {
              tags "Microsoft Azure - Azure Container Registry"

            }
          }

          azWebAppPlan -> azFuncVNetwork "Connected to" "FrontendSubnet" {
            properties {
              "URL" "https://www.example.com"
            }
            tags "Microsoft Azure - Connections"
          }
        }
      }
    }


  }

  views {
    systemContext azureFunctionApp "azFunc-SystemContext" {
      include *
      autolayout lr
    }
    container azureFunctionApp "azFunc-Containers" {
      include *
      autolayout
    }

    component apiContainer "Component" {
      include *
      autoLayout
    }

    deployment azureFunctionApp  "azFuncReferenceInstance"  "azFuncReferenceInstance" {
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