terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    kubectl = {
      source = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
    
    random = {
      source = "hashicorp/random"
    }
  }
}

# Generate a random password for Grafana if not provided
resource "random_password" "grafana" {
  length           = 16
  special          = true
  override_special = "_-!@#"
}

locals {
  admin_password = length(var.admin_password) > 0 ? var.admin_password : random_password.grafana.result
}

# Deploy the full Prometheus stack (including Grafana) using Helm
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

# Optionally, define service monitors to monitor all services in specified
# namespaces - this is needed for retrieving custom metrics from applications
# deployed in the cluster.
resource "kubectl_manifest" "service_monitor" {
  count = var.service_monitor == null ? 0 : 1
  override_namespace = var.namespace

  yaml_body = templatefile("${path.module}/service-monitor.yaml", {
    release      = helm_release.prometheus.name
    namespaces   = var.service_monitor.namespaces
    port         = var.service_monitor.port
    metrics_path = var.service_monitor.metrics_path
    interval     = var.service_monitor.interval
  })
}
