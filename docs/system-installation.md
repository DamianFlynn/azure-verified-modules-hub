# Setting Up a New System in GitHub for Azure Verified Solutions

In this guide, we'll set up a new system in GitHub that includes scripts and workflows (CI and CD Pipelines) to publish Infrastructure Code modules for Bicep based on the Microsoft Azure Verified Modules framework. We'll publish valid modules to two artifact repositories: an Azure Container Registry (Bicep Registry) and Azure TemplateSpecs.

## Steps to Set Up the System

### 1. Repository Configuration

First, we need to identify the organization, repository, and branch where we will host our system.

```sh
ORG="innofactororg"
REPO="azure-verified-solutions"
BRANCH="main"
```

We then create a new repository locally and commit the initialization.

```sh
git init && git add -A :/ && git commit -m "feat: initialization" && git branch -M $BRANCH
```

### 2. Secrets Configuration

Secrets are sensitive pieces of information that are used in your workflows but shouldn't be exposed directly in your code. They often include credentials, tokens, and other confidential data. In our setup, we have two main categories of secrets:

- **Validation and Deployment Secrets**: These secrets are used for deploying the Bicep modules.
- **Publishing Secrets**: These secrets are used for publishing the Bicep modules to the artifact repositories.

**Validation and Deployment Secrets**

These secrets are required for the GitHub Actions responsible for validating and deploying the Bicep modules.

| Secret Name         | Description                                                                                                                                                                                                                  |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ARM_TENANT_ID       | This is the unique identifier (GUID) of the Azure Active Directory (AAD) tenant. It ensures that the actions are performed within the correct AAD tenant.                                                                    |
| ARM_MGMTGROUP_ID    | This is the identifier of the Azure Management Group where the deployments will be managed. A Management Group helps to organize and manage multiple subscriptions.                                                          |
| ARM_SUBSCRIPTION_ID | This is the identifier of the Azure Subscription where the resources will be deployed. Subscriptions provide logical containers for resources in Azure.                                                                      |
| ARM_CLIENT_ID       | This is the client ID of the Azure Service Principal used to authenticate the actions. A Service Principal is an identity created for use with applications, hosted services, and automated tools to access Azure resources. |
| ARM_CLIENT_SECRET   | This is the client secret (password) of the Azure Service Principal. It’s used together with the client ID to authenticate the Service Principal.                                                                            |
| TOKEN_NAMEPREFIX    | This is a prefix that will be added to the names of all resources deployed by the GitHub Actions. It helps in identifying resources that were deployed through the pipeline.                                                 |

We can set these secrets using the following commands:

```sh
ARM_TENANT_ID="67481c72..."
ARM_MGMTGROUP_ID="Sandbox"
ARM_SUBSCRIPTION_ID="c868a8cf..."
ARM_CLIENT_ID="c079cb3c..."
ARM_CLIENT_SECRET="qpj8Q~z..."
TOKEN_NAMEPREFIX="avs"
```

**Publishing Secrets**

These secrets are required for the GitHub Actions responsible for publishing the Bicep modules to an Azure Container Registry (ACR) and Azure TemplateSpecs.
|PUBLISH_TENANT_ID | This is the unique identifier (GUID) of the Azure Active Directory (AAD) tenant. It ensures that the actions are performed within the correct AAD tenant. |
|PUBLISH_CLIENT_ID |This is the client ID of the Azure Service Principal used for publishing the modules. Similar to the validation and deployment secrets, this ID is used to authenticate the actions.
|PUBLISH_SUBSCRIPTION_ID|This is the identifier of the Azure Subscription where the Bicep modules will be published. This subscription will host the Azure Container Registry and the TemplateSpecs.
|PUBLISH_REGISTRY_SERVER| This is the URL of the Azure Container Registry where the Bicep modules will be published. ACR is a managed Docker container registry service that stores and manages container images.

```sh
PUBLISH_TENANT_ID="67481c72..."
PUBLISH_CLIENT_ID="c079cb3c..."
PUBLISH_SUBSCRIPTION_ID="a39403bb..."
PUBLISH_REGISTRY_SERVER="piacbicepregistryacr.azurecr.io"
```

**Housekeeping Secrets**

These secrets are used for general housekeeping tasks in the GitHub Actions workflows.

| Secret Name         | Description                                                                                                                               |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| BOT_ID              | This is the ID of the GitHub bot account. It's used to identify the bot account when performing actions in the repository.                |
| BOT_APP_PRIVATE_KEY | This is the access token for the GitHub bot account. It's used to authenticate the bot account when performing actions in the repository. |

```sh
BOT_APP_ID="213270"
BOT_APP_PRIVATE_KEY="e3e7e2b..."
```

### 3. Create and Push Repository to GitHub

Create a new repository on GitHub and push our local repository.

```sh
gh repo create $REPO --public --confirm -d "Azure Verified Solutions"
git remote add origin git@github.com:$ORG/$REPO.git
git push -u origin $BRANCH
```

### 4. Configure Branch Protection Rules

Branch protection rules are settings applied to a branch in a GitHub repository to enforce certain workflows and maintain code quality and security. In this section, we'll explain the branch protection settings that we're applying to the `main` branch of our repository.

### Branch Protection Settings

Here are the settings we're applying to the `main` branch:

- **Enforce Admins**: This setting ensures that even repository administrators must follow the branch protection rules. It prevents administrators from bypassing the rules.

```sh
-F "enforce_admins=true"
```

- **Required Status Checks**: Status checks ensure that code meets certain requirements (like passing tests) before it can be merged. Here, we set it to `null` because we are not specifying any particular status checks.

```sh
-F "required_status_checks=null"
```

- **Required Pull Request Reviews**: This setting ensures that pull requests must be reviewed before they can be merged. Specifically, we require at least one approving review and also require code owner reviews.

```sh
-F 'required_pull_request_reviews[required_approving_review_count]=1'
-F 'required_pull_request_reviews[require_code_owner_reviews]=true'
```

- **Restrictions on Users and Teams**: These settings can restrict who can push to the branch. We leave them empty (null) to not restrict specific users or teams.

```sh
-F 'restrictions[users][]'
-F 'restrictions[teams][]'
```

- **Required Linear History**: This setting ensures that the branch history does not contain any merge commits, which helps to maintain a clean and readable commit history.

```sh
-F "required_linear_history=true"
```

- **Allow Force Pushes**: This setting allows force pushes to the branch. Force pushes are typically discouraged because they can overwrite commit history, but we allow them here for flexibility.

```sh
-F "allow_force_pushes=true"
```

- **Allow Deletions**: This setting allows the branch to be deleted. While this might be useful in some workflows, it should be used cautiously.

```sh
-F "allow_deletions=true"
```

- **Block Creations**: This setting prevents new branches from being created off the protected branch, which can be useful to control the workflow tightly.

```sh
-F "block_creations=true"
```

- **Required Conversation Resolution**: This setting requires all comments in a pull request to be resolved before the PR can be merged. It ensures that any issues or questions raised during the review process are addressed.

```sh
-F "required_conversation_resolution=true"
```

- **Lock Branch**: This setting prevents changes to the branch. We're setting this to `false` to allow changes.

```sh
-F "lock_branch=false"
```

- **Allow Fork Syncing**: This setting allows branches from forks of the repository to be kept in sync with the protected branch. It's useful for collaborators who work on forks.

```sh
-F "allow_fork_syncing=true"
```

- **Require Last Push Approval**: This setting ensures that the latest changes pushed to the branch are approved before merging. It adds an extra layer of review and validation.

```sh
-F "require_last_push_approval=true"
```

#### Applying the Branch Protection Rules

We apply these settings to the `main` branch using the following command:

```sh
gh api -X PUT \
    /repos/$ORG/$REPO/branches/$BRANCH/protection \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -F "enforce_admins=true" \
    -F "required_status_checks=null" \
    -F 'required_pull_request_reviews[required_approving_review_count]=1' \
    -F 'required_pull_request_reviews[require_code_owner_reviews]=true' \
    -F 'restrictions[users][]' \
    -F 'restrictions[teams][]' \
    -F "required_linear_history=true"\
    -F "allow_force_pushes=true" \
    -F "allow_deletions=true" \
    -F "block_creations=true" \
    -F "required_conversation_resolution=true" \
    -F "lock_branch=false"\
    -F "allow_fork_syncing=true" \
    -F "restrictions=null" \
    -F "require_last_push_approval=true"
```

By configuring these branch protection rules, we ensure that our `main` branch maintains high standards of code quality and security. These settings enforce code reviews, linear commit history, and resolution of discussions, while also allowing necessary flexibility like force pushes and branch deletions. This helps us maintain a robust and well-managed codebase.

### 5. Configure GitHub Secrets

Set up the secrets required for the GitHub Actions.

**Validation and Deployment Secrets**

```sh
gh secret set ARM_TENANT_ID -b"$ARM_TENANT_ID" --repo $ORG/$REPO
gh secret set ARM_MGMTGROUP_ID -b"$ARM_MGMTGROUP_ID" --repo $ORG/$REPO
gh secret set ARM_SUBSCRIPTION_ID -b"$ARM_SUBSCRIPTION_ID" --repo $ORG/$REPO
AZURE_CREDENTIALS="{\"clientId\": \"$ARM_CLIENT_ID\", \"clientSecret\": \"$ARM_CLIENT_SECRET\", \"subscriptionId\": \"$ARM_SUBSCRIPTION_ID\", \"tenantId\": \"$ARM_TENANT_ID\" }"
gh secret set AZURE_CREDENTIALS -b"$AZURE_CREDENTIALS" --repo $ORG/$REPO
gh secret set TOKEN_NAMEPREFIX -b"$TOKEN_NAMEPREFIX" --repo $ORG/$REPO
```

**Publishing Secrets**

```sh
gh secret set PUBLISH_TENANT_ID -b"$PUBLISH_TENANT_ID" --repo $ORG/$REPO
gh secret set PUBLISH_SUBSCRIPTION_ID -b"$PUBLISH_SUBSCRIPTION_ID" --repo $ORG/$REPO
gh secret set PUBLISH_CLIENT_ID -b"$PUBLISH_CLIENT_ID" --repo $ORG/$REPO
gh secret set PUBLISH_REGISTRY_SERVER -b"$PUBLISH_REGISTRY_SERVER" --repo $ORG/$REPO
```

**Housekeeping Secrets**

```sh
gh secret set BOT_APP_ID -b"$BOT_APP_ID" --repo $ORG/$REPO
gh secret set BOT_APP_PRIVATE_KEY -b"$BOT_APP_PRIVATE_KEY" --repo $ORG/$REPO
```

### Summary

By following these steps, we have successfully:

- Initialized a new GitHub repository for Azure Verified Solutions.
- Configured branch protection rules.
- Set up secrets required for validation, deployment, and publishing of Bicep modules.

This setup ensures that we can efficiently validate, deploy, and publish our Bicep modules using GitHub Actions with secure and streamlined workflows.
