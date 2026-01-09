output "grafana_password" {
  description = "The Grafana admin password."
  value       = local.admin_password
  sensitive   = true
}
