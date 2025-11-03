terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

# Create a key vault for the current tenant
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.sku

  soft_delete_retention_days = var.soft_delete_retention_days
  enable_rbac_authorization  = var.enable_rbac_authorization
}

# Grant the current principal access to the key vault
resource "azurerm_role_assignment" "this" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
  count                = var.assign_kv_role ? 1 : 0
}

# Store the specified secrets in the key vault
resource "azurerm_key_vault_secret" "this" {
  for_each = var.secrets

  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.this.id
  depends_on   = [azurerm_role_assignment.this]
}
