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

output "gh_tenant_id" {
  description = "The GitHub OIDC tenant ID."
  value       = module.identity_github.tenant_id
}

output "gh_client_id" {
  description = "The GitHub OIDC client ID."
  value       = module.identity_github.client_id
}

output "gh_subscription_id" {
  description = "The GitHub OIDC subscription ID."
  value       = module.identity_github.subscription_id
}
