output "rg_name" {
  description = "The name of the resource group."
  value       = var.resource_group_name
}

output "pg_name" {
  description = "The name of the PostgreSQL server."
  value       = module.postgres.name
}

output "aks_name" {
  description = "The name of the AKS cluster."
  value       = module.kubernetes.name
}

output "keyvault_name" {
  description = "The name of the Azure Key Vault."
  value       = module.keyvault.name
}

output "acr_login_server" {
  description = "The login server of the shared Azure Container Registry."
  value       = data.azurerm_container_registry.shared.login_server
}
