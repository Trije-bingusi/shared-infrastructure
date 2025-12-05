#!/usr/bin/env bash
# =====================================================================
# Script: config.sh
# Description: Retrieves configuration of Azure resources provisioned
#              by reading Terraform outputs.
# Usage: source this script to set environment variables for resource names.
# =====================================================================

INFRA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../infra" && pwd)"
echo "Loading Terraform outputs from $INFRA_DIR"

pushd "$INFRA_DIR" > /dev/null

terraform init > /dev/null
RG_NAME=$(terraform output -raw rg_name)
AKS_NAME=$(terraform output -raw aks_name)
PG_NAME=$(terraform output -raw pg_name)

popd > /dev/null
