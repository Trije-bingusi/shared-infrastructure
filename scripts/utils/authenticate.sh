#!/usr/bin/env bash
# =====================================================================
# Script: authenticate.sh
# Description: Authenticates to an Azure AKS cluster identified by the
#              AKS_NAME and RG_NAME environment variables.
# Usage: Set AKS_NAME and RG_NAME environment variables (can be done by
#        sourcing config.sh), then run this script.

# Check that parameters are provided as environment variables
if [[ -z "${AKS_NAME:-}" ]]; then
    echo "Error: AKS_NAME environment variable is not set."
    exit 1
fi

if [[ -z "${RG_NAME:-}" ]]; then
    echo "Error: RG_NAME environment variable is not set."
    exit 1
fi

# Authenticate to the AKS cluster
echo "Authenticating to AKS cluster '$AKS_NAME' in resource group '$RG_NAME'"
az aks get-credentials -n "$AKS_NAME" -g "$RG_NAME" --overwrite-existing

# Verify authentication
CURRENT_CLUSTER=$(kubectl config current-context 2>/dev/null)
EXPECTED_CLUSTER="$AKS_NAME"

if [[ "$CURRENT_CLUSTER" != *"$EXPECTED_CLUSTER"* ]]; then
    echo "Error: Not authenticated to the correct cluster. Expected '$EXPECTED_CLUSTER', got '$CURRENT_CLUSTER'."
    exit 1
fi

if kubectl version >/dev/null 2>&1; then
    current_cluster=$(kubectl config current-context)
    if [[ "$current_cluster" != *"$AKS_NAME"* ]]; then
        echo "Error: Current kubectl context '$current_cluster' does not match expected AKS cluster '$AKS_NAME'."
        exit 1
    fi
    echo "Successfully authenticated to AKS cluster '$AKS_NAME'."
    exit 0
else
    echo "Error: Failed to authenticate to AKS cluster '$AKS_NAME'."
    exit 1
fi
