output "id" {
  description = "The ID of the Container Registry."
  value       = azurerm_container_registry.this.id
}

output "login_server" {
  description = "The login server of the Container Registry."
  value       = azurerm_container_registry.this.login_server
}
