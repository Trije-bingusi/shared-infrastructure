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

output "k8s_ingress_ip" {
  description = "The public IP address of the NGINX Ingress controller."
  value = local.k8s_ingress_ip
}

output "k8s_keycloak_admin_password" {
  description = "The Keycloak admin password."
  value       = random_password.keycloak_admin.result
  sensitive   = true
}

output "k8s_grafana_password" {
  description = "The Grafana admin password."
  value       = module.monitoring.grafana_password
  sensitive   = true
}
