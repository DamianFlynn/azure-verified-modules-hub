# Azure Verified Solutions

The Azure Verified Solutions is a platform designed to host and manage Azure Verified Modules for downstream organizations. The project aims to provide a centralized repository for customizing and extending new and existing modules, which are available in the Public Azure Bicep Registry, Enabling downstream organizations to leverage the benefits of Azure Verified Modules, combined with formal architecture documentation enabled trough the use of the C4 Model while maintaining control over their infrastructure as code, publishing to the enterprises own hosted repository (Azure Container Registry for Bicep, and Azure Template Specs).

## Position within the Ecosystem

The Azure Verified Solutions repository is positioned as an extension of the Azure Bicep Registry, providing a platform for downstream organizations to customize and extend the registry to meet their specific needs. The project is designed to work seamlessly with the Azure Verified Modules Registry, leveraging its governance and management capabilities to ensure the integrity and security of the modules hosted within the Azure Verified Solutions.

## Key Features

- Hosting and management of Azure Verified Modules for downstream organizations
- Customization and extension of the published public Azure Verified Modules
- Governance and management of modules through `codeowners` and version files
- Integration with Azure Lighthouse and Azure Policy for compliance and security
- Publishing to Azure Container Registry and Azure Template Specs
- Integration with Azure Deployment Environments for streamlined deployment
- Use of Structurizr for architecture documentation based on the C4 Model

## Benefits

- Provides a centralized repository for customizing and extending the published Bicep Azure Verified Modules
- Allows downstream organizations to leverage the benefits of Azure Verified Modules while maintaining control over their infrastructure as code
- Ensures compliance and security through integration with Azure Lighthouse and Azure Policy
- Streamlines deployment through integration with Azure Deployment Environments

## What is the difference between the AVM Bicep Registry and Azure-Verified-Solutions? How do they come together?

The Public Bicep Registry, supported by the AVM and BRM repositories, is Microsoft's official Bicep Registry for first-party-supported Bicep modules. It has been in existence for a while and has garnered significant contributions.

As various teams within Microsoft collaborated to establish a unified Infrastructure as Code (IaC) approach and library, the Azure Verified Modules (AVM) initiative was launched to bridge gaps by defining specifications for both Bicep and Terraform modules.

In the BRM repository, "vanilla modules" (non-AVM modules) can be found in the /modules folder, while AVM modules are located in the /avm folder. Both are published to the same endpoint, the Public Bicep Registry. AVM Bicep modules are published under a dedicated namespace, using the avm/res & avm/ptn prefixes to distinguish them from the Public Registry's vanilla modules.

Azure-Verified-Solutions modules adhere to AVM specifications and are published to our Enterprise Bicep Registry and Template Spec. These modules are developed and maintained by our organization and partners. They are considered the most reliable and secure, recommended for use in production environments. The scope of these modules is to address features and policies missing from the AVM-published Public Bicep Registry or to override parameters with opinionated governance decisions to align with our governance and security principles. Additionally, these modules include proprietary resources and patterns to sustain the delivery of versioned solutions and platforms for our teams and partners in the form of utilities and solutions.

- Going forward, AVM will become the single Microsoft standard for Bicep modules, published to the Public Bicep Registry via the BRM repository.
- In the upcoming period, existing vanilla modules will be retired or migrated to AVM, and new modules will be developed according to AVM specifications.
- The Azure-Verified-Solutions modules will be published to the Enterprise Bicep Registry and Template Spec and will be selected in preference to the modules published in the Public Bicep Registry.

## Getting Started

To get started with the Azure Verified Solutions, please read the [Contributing Guidelines](./CONTRIBUTING.md) and then follow the step-by-step guide to contributing to Azure Verified Modules in the [Contributing Steps](docs/system/contribution/00-index.md) Documentation.
