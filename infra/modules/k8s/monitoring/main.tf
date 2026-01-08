terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    
    random = {
      source = "hashicorp/random"
    }
  }
}

resource "helm_release" "prometheus" {
  name       = var.release_name
  namespace  = var.namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_version

  create_namespace = true
  values = [
    templatefile("${path.module}/values.yaml", {
      grafana_path    = var.grafana_path
      ingress         = var.grafana_ingress
      retention       = var.retention
      admin_password  = local.admin_password
      requests_memory = var.requests_memory
      requests_cpu    = var.requests_cpu
      limits_memory   = var.limits_memory
      limits_cpu      = var.limits_cpu
    })
  ]
}

resource "random_password" "grafana" {
  length           = 16
  special          = true
  override_special = "_-!@#"
}

locals {
  admin_password = length(var.admin_password) > 0 ? var.admin_password : random_password.grafana.result
}
