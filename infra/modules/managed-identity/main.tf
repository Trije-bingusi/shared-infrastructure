terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

data "azurerm_client_config" "current" {}

# Create the identity and assign the specified roles
resource "azurerm_user_assigned_identity" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_role_assignment" "this" {
  for_each = { for i, role in var.roles : i => role }

  principal_id         = azurerm_user_assigned_identity.this.principal_id
  role_definition_name = each.value.name
  scope                = each.value.scope
}

# Optionally create GitHub OIDC federated identity credential
resource "azurerm_federated_identity_credential" "gh" {
  for_each = toset(var.github_federated_identity_subjects)

  name                = "github-oidc-${replace(each.key, "/[^A-Za-z-]/", "")}"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.this.id
  issuer              = "https://token.actions.githubusercontent.com"

  subject  = each.value
  audience = ["api://AzureADTokenExchange"]
}
