# Prod environment infrastructure
# References shared ACR and creates Production specific resources (AKS, PostgreSQL, KeyVault)

# Reference existing ACR from shared infrastructure
data "azurerm_container_registry" "shared" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
}

module "postgres" {
  source              = "../../modules/postgres-flexible"
  resource_group_name = var.resource_group_name
  location            = coalesce(var.pg_location, var.location)
  name                = var.pg_name
  pg_version          = var.pg_version
  sku                 = var.pg_sku
  storage_mb          = var.pg_storage_mb
}

module "kubernetes" {
  source              = "../../modules/aks"
  resource_group_name = var.resource_group_name
  location            = coalesce(var.aks_location, var.location)
  name                = var.aks_name
  node_count          = var.aks_node_count
  node_vm_size        = var.aks_node_vm_size

  # Allow the AKS cluster to pull images from the shared ACR
  attached_container_registry = data.azurerm_container_registry.shared.id
}

# Store information on resources in Key Vault
module "keyvault" {
  source              = "../../modules/keyvault"
  name                = var.keyvault_name
  resource_group_name = var.resource_group_name
  location            = var.location
  secrets = {
    "rg-name"           = var.resource_group_name
    "acr-login-server"  = data.azurerm_container_registry.shared.login_server
    "pg-name"           = module.postgres.name
    "pg-fqdn"           = module.postgres.fqdn
    "pg-admin-username" = module.postgres.administrator_login
    "pg-admin-password" = module.postgres.administrator_password
    "aks-kube-config"   = module.kubernetes.kube_config
    "aks-name"          = module.kubernetes.name
  }
}

# Managed identity for microservices (push to ACR, deploy to AKS, access Key Vault secrets)
module "identity_microservices" {
  source              = "../../modules/managed-identity"
  name                = var.identity_microservices_name
  resource_group_name = var.resource_group_name
  location            = var.location

  roles = [
    { name = "Azure Kubernetes Service Cluster User Role", scope = module.kubernetes.id },
    { name = "Key Vault Secrets User", scope = module.keyvault.id },
    { name = "AcrPush", scope = data.azurerm_container_registry.shared.id },
  ]
}
