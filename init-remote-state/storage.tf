locals {
  storage_account_name = (
    length(var.storage_account_name) > 0 ?
    var.storage_account_name :
    "tfstate${random_string.storage_account_suffix.result}"
  )
}

resource "random_string" "storage_account_suffix" {
  length  = 8
  upper   = false
  special = false
}

resource "azurerm_storage_account" "tfstate" {
  name                            = local.storage_account_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "tfstate" {
  name                  = var.storage_container_name
  storage_account_name = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}
