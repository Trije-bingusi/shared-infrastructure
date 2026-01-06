#!/usr/bin/env bash
# =====================================================================
# Script: manage-services.sh
# Description: Starts or stops Azure AKS and PostgreSQL Flexible Server
#              for a specified environment.
# Usage: ./scripts/manage-services.sh <env> start|stop
# =====================================================================

set -euo pipefail

# Validate arguments
ENVIRONMENT=${1:-}
ACTION=${2:-}
if [[ -z "$ENVIRONMENT" || -z "$ACTION" ]]; then
  echo "Usage: $0 <env> start|stop"
  exit 1
fi

if [[ "$ACTION" != "start" && "$ACTION" != "stop" ]]; then
  echo "Invalid argument: must be 'start' or 'stop'"
  exit 1
fi

# Load Terraform outputs
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/config.sh" "$ENVIRONMENT"

echo "Retrieved resource names from Terraform outputs:"
echo "   Resource Group: $RG_NAME"
echo "   AKS Cluster:    $AKS_NAME"
echo "   PostgreSQL:     $PG_NAME"

# Get state of services
AKS_STATE=$(
    az aks show --name "$AKS_NAME" --resource-group "$RG_NAME" \
    --query "powerState.code" -o tsv 2>/dev/null || echo "Unknown"
)

PG_STATE=$(
    az postgres flexible-server show --name "$PG_NAME" --resource-group "$RG_NAME" \
    --query "state" -o tsv 2>/dev/null || echo "Unknown"
)

# Start or stop services based on the input argument
if [[ "$ACTION" == "start" ]]; then
  echo "Starting AKS cluster..."

  if [[ "$AKS_STATE" == "Running" ]]; then
    echo "AKS cluster is already running."
  else
    echo "Starting AKS cluster..."
    az aks start --name "$AKS_NAME" --resource-group "$RG_NAME"
  fi

  if [[ "$PG_STATE" == "Ready" ]]; then
    echo "PostgreSQL Flexible Server is already running."
  else
    echo "Starting PostgreSQL Flexible Server..."
    az postgres flexible-server start --name "$PG_NAME" --resource-group "$RG_NAME"
  fi

  echo "All services started."

else
  echo "Stopping services..."

  if [[ "$AKS_STATE" == "Stopped" ]]; then
    echo "AKS cluster is already stopped."
  else
    echo "Stopping AKS cluster..."
    az aks stop --name "$AKS_NAME" --resource-group "$RG_NAME"
  fi

  if [[ "$PG_STATE" == "Stopped" ]]; then
    echo "PostgreSQL Flexible Server is already stopped."
  else
    echo "Stopping PostgreSQL Flexible Server..."
    az postgres flexible-server stop --name "$PG_NAME" --resource-group "$RG_NAME"
  fi

  echo "All services stopped."
fi
