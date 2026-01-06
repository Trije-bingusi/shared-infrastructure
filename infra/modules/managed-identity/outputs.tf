output "name" {
  description = "The name of the Managed Identity."
  value       = azurerm_user_assigned_identity.this.name
}

output "id" {
  description = "The ID of the Managed Identity."
  value       = azurerm_user_assigned_identity.this.id
}

output "client_id" {
  description = "Client ID of the Managed Identity."
  value       = azurerm_user_assigned_identity.this.client_id
}

output "tenant_id" {
  description = "Tenant ID of the Managed Identity."
  value       = azurerm_user_assigned_identity.this.tenant_id
}

output "subscription_id" {
  description = "Subscription ID of the Managed Identity. Uses the current user subscription ID."
  value       = data.azurerm_client_config.current.subscription_id
}
