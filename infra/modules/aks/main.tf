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

# Generate DNS prefix to use if not provided
resource "random_string" "dns_prefix_suffix" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}

locals {
  dns_prefix = coalesce(
    var.dns_prefix,
    "${var.name}-${random_string.dns_prefix_suffix.result}"
  )
}

# Define the kubernetes cluster
resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_prefix          = local.dns_prefix

  default_node_pool {
    name       = var.node_pool_name
    vm_size    = var.node_vm_size
    node_count = var.node_count

    # Explicitly set default upgrade settings to prevent circular diff
    upgrade_settings {
      max_surge                     = "10%"
      drain_timeout_in_minutes      = 0
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

# Attach specified container registries
resource "azurerm_role_assignment" "acr_attachment" {
  count = var.attached_container_registry == null ? 0 : 1
  principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.attached_container_registry
  skip_service_principal_aad_check = true
}
