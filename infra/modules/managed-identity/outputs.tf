output "name" {
  description = "The name of the Managed Identity."
  value       = azurerm_user_assigned_identity.this.name
}

output "id" {
  description = "The ID of the Managed Identity."
  value       = azurerm_user_assigned_identity.this.id
}
