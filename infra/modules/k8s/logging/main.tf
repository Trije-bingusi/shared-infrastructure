terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

resource "helm_release" "loki" {
  name       = var.loki_release_name
  namespace  = var.namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = var.loki_chart_version

  create_namespace = true

  values = [
    templatefile("${path.module}/loki-values.yaml", {
      retention    = var.retention
      requests_cpu = var.requests_cpu
      requests_mem = var.requests_memory
      limits_cpu   = var.limits_cpu
      limits_mem   = var.limits_memory
    })
  ]
}

resource "helm_release" "promtail" {
  name       = var.promtail_release_name
  namespace  = var.namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  version    = var.promtail_chart_version

  depends_on = [helm_release.loki]

  values = [
    templatefile("${path.module}/promtail-values.yaml", {
      loki_url = "http://${helm_release.loki.name}.${var.namespace}.svc.cluster.local:3100/loki/api/v1/push"
    })
  ]
}
