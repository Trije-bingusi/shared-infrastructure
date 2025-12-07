#!/usr/bin/env bash

# Configure names of created namespaces
SERVICES_NAMESPACE=rso
INGRESS_NAMESPACE=ingress-nginx
INGRESS_RELEASE=ingress-nginx

# Fetch configuration and authenticate to the cluster
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/config.sh"
source "${SCRIPT_DIR}/utils/authenticate.sh"

# Utility function for creating a namespace if it doesn't exist
create_namespace() {
  local namespace=$1
  if kubectl get namespace "$namespace" >/dev/null 2>&1; then
    echo "Namespace '$namespace' already exists."
  else
    echo "Creating namespace '$namespace'."
    kubectl create namespace "$namespace"
  fi
}

# Create the shared namespace for our services and a namespace for Ingress
create_namespace "$SERVICES_NAMESPACE"
create_namespace "$INGRESS_NAMESPACE"

# Install NGINX Ingress Controller
echo "Adding Helm repo for ingress-nginx"
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx >/dev/null
helm repo update >/dev/null

echo "Installing NGINX Ingress Controller via Helm"
INGRESS_VALUES_PATH="${SCRIPT_DIR}/ingress/values.yaml"
helm upgrade --install "$INGRESS_RELEASE" ingress-nginx/ingress-nginx \
  --version "4.14.1" \
  --namespace "$INGRESS_NAMESPACE" \
  --values "$INGRESS_VALUES_PATH"
  
# Verify Ingress installation (fetch external IP)
n_retries=40
wait_seconds=5
wait_total_seconds=$((n_retries * wait_seconds))
echo "Waiting up to $wait_total_seconds seconds for Ingress controller EXTERNAL-IP"

for ((i=1; i<=n_retries; i++)); do
  IP=$(
    kubectl -n "$INGRESS_NAMESPACE" get svc "$INGRESS_RELEASE-controller" \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true
  )
  
  if [[ -n "$IP" ]]; then
    echo "Ingress Load Balancer IP: $IP"
    exit 0
  fi
  sleep $wait_seconds
done

echo "Timeout waiting for Ingress external IP."
kubectl -n "$INGRESS_NAMESPACE" get svc "$INGRESS_RELEASE-controller" -o wide || true
exit 1

