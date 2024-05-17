#!/bin/bash
ORG="DamianFlynn"
REPO="azure-verified-modules-hub"
BRANCH="main"
gh repo create $REPO --public --confirm -d "Azure Verified Modules Hub"
gh api -X PUT \
    /repos/$ORG/$REPO/branches/$BRANCH/protection \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -F "enforce_admins=true" \
    -F "required_status_checks=null"
    -F 'required_pull_request_reviews[required_approving_review_count]=1' \
    -F 'required_pull_request_reviews[require_code_owner_reviews]=true' \
    -F 'restrictions[users]=null' \
    -F 'restrictions[teams]=null' \
    -F "required_linear_history=true"\
    -F "allow_force_pushes=true" \
    -F "allow_deletions=true" \
    -F "block_creations=true" \
    -F "required_conversation_resolution=true" \
    -F "lock_branch=true"\
    -F "allow_fork_syncing=true" \
    -F "restrictions=null" \


# Secrets for the Github Actions responsible for valiation and deployment of the Bicep modules
gh secret set ARM_TENANT_ID -b"<your-secret-value>"
gh secret set ARM_MGMTGROUP_ID -b"<your-secret-value>"
gh secret set ARM_SUBSCRIPTION_ID -b"<your-secret-value>"
gh secret set AZURE_CREDENTIALS -b"<your-secret-value>"
gh secret set TOKEN_NAMEPREFIX -b"<your-secret-value>"

# Secrets for the Github Actions responsible for publishing the Bicep modules
gh secret set PUBLISH_TENANT_ID -b"<your-secret-value>"
gh secret set PUBLISH_SUBSCRIPTION_ID -b"<your-secret-value>"
gh secret set PUBLISH_CLIENT_ID -b"<your-secret-value>"
gh secret set PUBLISH_REGISTRY_SERVER -b"<your-secret-value>"

