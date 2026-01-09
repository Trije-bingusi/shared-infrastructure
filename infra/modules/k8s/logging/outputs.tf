output "loki_url" {
  description = "The URL of the Loki service inside the cluster."
  value       = "http://${helm_release.loki.name}-gateway.${var.namespace}.svc.cluster.local"
}