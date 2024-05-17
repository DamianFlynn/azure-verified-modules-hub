#!/bin/bash
# Create a new repository locally
git init && git add -A :/ && git commit -m "feat: initialization" && git branch -M main

# Create a new repository on Github
ORG="DamianFlynn"
REPO="azure-verified-modules-hub"
BRANCH="main"
ARM_TENANT_ID="d993d9e4-644e-4d0a-ba80-0e010d0ea023"
ARM_MGMTGROUP_ID="brightminds"
ARM_SUBSCRIPTION_ID="7d443596-7c4e-477b-8213-12ef64c1858f"
ARM_CLIENT_ID="15d7dc3d-727a-4ec6-91bd-12c30f4eee02"
ARM_CLIENT_SECRET="..."
TOKEN_NAMEPREFIX="test"

gh repo create $REPO --public --confirm -d "Azure Verified Modules Hub"
git remote add origin git@github.com:DamianFlynn/azure-verified-modules-hub.git
git push -u origin main

# Configure the Branch Protection Rules
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
    -F "lock_branch=true"\
    -F "allow_fork_syncing=true" \
    -F "restrictions=null" \
    -F "require_last_push_approval=true"

# Secrets for the Github Actions responsible for valiation and deployment of the Bicep modules

gh secret set ARM_TENANT_ID -b"$ARM_TENANT_ID"
gh secret set ARM_MGMTGROUP_ID -b"$ARM_MGMTGROUP_ID"
gh secret set ARM_SUBSCRIPTION_ID -b"$ARM_SUBSCRIPTION_ID"
AZURE_CREDENTIALS="{\"clientId\": \"$ARM_CLIENT_ID\", \"clientSecret\": \"$ARM_CLIENT_SECRET\", \"subscriptionId\": \"$ARM_SUBSCRIPTION_ID\", \"tenantId\": \"$ARM_TENANT_ID\" }"
gh secret set AZURE_CREDENTIALS -b"$AZURE_CREDENTIALS"
gh secret set TOKEN_NAMEPREFIX -b"$TOKEN_NAMEPREFIX"

# Secrets for the Github Actions responsible for publishing the Bicep modules
gh secret set PUBLISH_TENANT_ID -b"<your-secret-value>"
gh secret set PUBLISH_SUBSCRIPTION_ID -b"<your-secret-value>"
gh secret set PUBLISH_CLIENT_ID -b"<your-secret-value>"
gh secret set PUBLISH_REGISTRY_SERVER -b"<your-secret-value>"

