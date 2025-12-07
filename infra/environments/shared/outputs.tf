output "rg_name" {
  description = "The name of the resource group."
  value       = var.resource_group_name
}

output "acr_id" {
  description = "The ID of the Azure Container Registry."
  value       = module.acr.id
}

output "acr_login_server" {
  description = "The login server of the Azure Container Registry."
  value       = module.acr.login_server
}

output "acr_name" {
  description = "The name of the Azure Container Registry."
  value       = var.acr_name
}
