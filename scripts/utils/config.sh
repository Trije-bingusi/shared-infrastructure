#!/usr/bin/env bash
# =====================================================================
# Script: config.sh
# Description: Retrieves configuration of Azure resources provisioned
#              by reading Terraform outputs of a specified environment.
# Usage: source config.sh <environment>
# =====================================================================

# Check input arguments
ENVIRONMENT=$1
if [[ -z "$ENVIRONMENT" ]]; then
  echo "Usage: source config.sh <environment>"
  exit 1
fi

# Make sure the environment exists (use CONFIG_SCRIPT_DIR to avoid shadowing caller's SCRIPT_DIR)
CONFIG_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="${CONFIG_SCRIPT_DIR}/../../infra/environments/${ENVIRONMENT}"
if [[ ! -d "$INFRA_DIR" ]]; then
    echo "Error: Environment '${ENVIRONMENT}' does not exist."
    exit 1
fi

# Load Terraform outputs
echo "Loading Terraform outputs from $INFRA_DIR"
pushd "$INFRA_DIR" > /dev/null

terraform init > /dev/null
RG_NAME=$(terraform output -raw rg_name)
AKS_NAME=$(terraform output -raw aks_name)
PG_NAME=$(terraform output -raw pg_name)

popd > /dev/null
