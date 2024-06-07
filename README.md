# Azure Verified Module Hub

The Azure Verified Module Hub (AVMH) is a platform designed to host and manage Azure Verified Modules for downstream organizations. The project aims to provide a centralized repository for customizing and extending the Azure Bicep Registry, allowing downstream organizations to leverage the benefits of Azure Verified Modules while maintaining control over their infrastructure as code.

## Position within the Ecosystem

The AVMH is positioned as an extension of the Azure Bicep Registry, providing a platform for downstream organizations to customize and extend the registry to meet their specific needs. The project is designed to work seamlessly with the Azure Verified Modules Registry, leveraging its governance and management capabilities to ensure the integrity and security of the modules hosted within the AVMH.

## Key Features

- Hosting and management of Azure Verified Modules for downstream organizations
- Customization and extension of the published public Azure Verified Modules
- Governance and management of modules through codeowners and version files
- Integration with Azure Lighthouse and Azure Policy for compliance and security
- Publishing to Azure Container Registry and Azure Template Specs
- Integration with Azure Deployment Environments for streamlined deployment

## Benefits

- Provides a centralized repository for customizing and extending the published Bicep Azure Verified Modules
- Allows downstream organizations to leverage the benefits of Azure Verified Modules while maintaining control over their infrastructure as code
- Ensures compliance and security through integration with Azure Lighthouse and Azure Policy
- Streamlines deployment through integration with Azure Deployment Environments

## Getting Started

To get started with the AVMH, please follow these steps:

1. Clone the AVMH repository
1. Configure the repository with your organization's settings
1. Publish your custom modules to the AVMH
1. Integrate the AVMH with your Azure environment
1. Start customizing and extending Azure Verified Modules for your organization

## Structurizr

The Structurizr diagram below shows the high-level architecture of the Azure Verified Module Hub.

The following will install the container on your local machine:

```sh
docker pull ghcr.io/avisi-cloud/structurizr-site-generatr
docker run -it --rm ghcr.io/avisi-cloud/structurizr-site-generatr --help
docker run -it --rm ghcr.io/avisi-cloud/structurizr-site-generatr version
```

With a working installation, we can proceed to generate the diagram:

```sh
docker run -it --rm -v /Users/damianflynn/Developer/DamianFlynn/Azure-Verified-Module-Hub:/var/model ghcr.io/avisi-cloud/structurizr-site-generatr generate-site -w workspace.dsl
```

This is create a fresh version of the static site in the build directory.

Now, to develop the site locally, we can use the following command:

```sh
docker run -it --rm -v /Users/damianflynn/Developer/DamianFlynn/Azure-Verified-Module-Hub:/var/model -p 8080:8080 ghcr.io/avisi-cloud/structurizr-site-generatr serve -w workspace.dsl
```
