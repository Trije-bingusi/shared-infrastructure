output "id" {
  description = "The ID of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.id
}

output "fqdn" {
  description = "The fully qualified domain name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "administrator_login" {
  description = "The administrator login name for the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.administrator_login
}

output "administrator_password" {
  description = "The administrator password for the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.administrator_password
  sensitive   = true
}
