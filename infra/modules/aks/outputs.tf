output "client_certificate" {
  description = "The client certificate for the Kubernetes cluster."
  value       = azurerm_kubernetes_cluster.this.kube_config[0].client_certificate
  sensitive   = true
}

output "kube_config" {
  description = "The kube config for the Kubernetes cluster."
  value       = azurerm_kubernetes_cluster.this.kube_config[0]
  sensitive   = true
}

output "kube_config_raw" {
  description = "The raw kube config for the Kubernetes cluster."
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "id" {
  description = "The ID of the Kubernetes cluster."
  value       = azurerm_kubernetes_cluster.this.id
}

output "name" {
  description = "The name of the Kubernetes cluster."
  value       = azurerm_kubernetes_cluster.this.name
}
