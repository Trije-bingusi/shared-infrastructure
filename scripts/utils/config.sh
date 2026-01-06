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
popd > /dev/null

function get_terraform_output() {
    local output_name=$1
    pushd "$INFRA_DIR" > /dev/null
    val=$(terraform output -raw "$output_name")
    popd > /dev/null
    echo "$val"
}

RG_NAME=$(get_terraform_output rg_name)
AKS_NAME=$(get_terraform_output aks_name)
PG_NAME=$(get_terraform_output pg_name)
KEYVAULT_NAME=$(get_terraform_output keyvault_name)
