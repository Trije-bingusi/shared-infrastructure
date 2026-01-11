terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

# Deploy NATS using Helm
resource "helm_release" "nats" {
  name       = var.release_name
  namespace  = var.namespace
  repository = "https://nats-io.github.io/k8s/helm/charts"
  chart      = "nats"
  version    = var.chart_version

  create_namespace = true

  values = [
    templatefile("${path.module}/values.yaml", {
      replicas       = var.replicas
      jetstream      = var.jetstream
      persistence    = var.persistence
      storage_size   = var.storage_size
      memory_request = var.memory_request
      cpu_request    = var.cpu_request
      memory_limit   = var.memory_limit
      cpu_limit      = var.cpu_limit
    })
  ]
}

