#!/usr/bin/env bash
# =====================================================================
# Script: configure-github-repo.sh
# Description: Creates a "dev" and "prod" environment in the specified
#              GitHub repository by adding necessary secrets and branch
#              protection rules.
# Usage: ./scripts/configure-github-repo.sh <github-repo>
# Example: ./scripts/configure-github-repo.sh Trije-bingusi/svc-notes
# =====================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Make sure GitHub repository argument is provided
GITHUB_REPO=${1:-}
if [[ -z "$GITHUB_REPO" ]]; then
    echo "Usage: $0 <github-repo>"
    exit 1
fi
# Ensure `gh` CLI is available
if ! command -v gh >/dev/null 2>&1; then
    echo "Error: GitHub CLI 'gh' is required but not installed."
    exit 2
fi

# Owner/repo validation
if [[ "$GITHUB_REPO" != */* ]]; then
    echo "Error: <github-repo> must be in the form 'owner/repo'"
    exit 1
fi

# Environments to create and configure
ENVS=(dev prod)

echo "Configuring GitHub repository: $GITHUB_REPO"

for env in "${ENVS[@]}"; do
    echo "\n== Environment: $env =="

    # Retrieve terraform output for this environment
    source "${SCRIPT_DIR}/utils/config.sh" "$env"
    CLIENT_ID=$(get_terraform_output gh_client_id)
    SUBSCRIPTION_ID=$(get_terraform_output gh_subscription_id)
    TENANT_ID=$(get_terraform_output gh_tenant_id)
    KEYVAULT_NAME=$(get_terraform_output keyvault_name)

    # Create environment if it doesn't exist (PUT is idempotent)
    echo "Creating environment (if missing)..."
    gh api -X PUT "repos/${GITHUB_REPO}/environments/${env}"

    # Set Azure-related secrets
    echo "Setting environment secrets"
    echo "$CLIENT_ID" | gh secret set AZURE_CLIENT_ID --env "$env" --repo "$GITHUB_REPO"
    echo "$SUBSCRIPTION_ID" | gh secret set AZURE_SUBSCRIPTION_ID --env "$env" --repo "$GITHUB_REPO"
    echo "$TENANT_ID" | gh secret set AZURE_TENANT_ID --env "$env" --repo "$GITHUB_REPO"

    # Set KEYVAULT_NAME as an environment-level environment variable
    echo "Setting environment variable KEYVAULT_NAME."
    echo "$KEYVAULT_NAME" | gh variable set KEYVAULT_NAME --env "$env" --repo "$GITHUB_REPO"

    echo "Environment '$env' configured."
done

echo "\nDone. The 'dev' and 'prod' environments exist and contain appropriate secrets and environment variables."


