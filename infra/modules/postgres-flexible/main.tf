terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}

# Generate credentials to be used if not provided through variables
resource "random_pet" "login" {
  length    = 2
  separator = ""
}

resource "random_password" "login" {
  length           = 16
  special          = true
  override_special = "_-!@#"
}

# Define the actual postgres server
resource "azurerm_postgresql_flexible_server" "this" {
  name                   = var.name
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.pg_version
  sku_name               = var.sku
  storage_mb             = var.storage_mb
  storage_tier           = var.storage_tier
  zone                   = var.zone
  administrator_login    = coalesce(var.administrator_login, random_pet.login.id)
  administrator_password = coalesce(var.administrator_password, random_password.login.result)
}

# Optionally allow all Azure services to access the server
# TODO: We should look into how to allow only a specific resource (such as our
# AKS cluster) instead of all Azure services.
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure" {
  count               = var.allow_all_azure_services ? 1 : 0
  name                = "AllowAllAzureServices"
  server_id           = azurerm_postgresql_flexible_server.this.id
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

