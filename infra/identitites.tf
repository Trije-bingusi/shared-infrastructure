# This file defines Managed Identities, meant to be used by various GitHub workflows
# to access the shared Azure resources securely.

# Identity for microservices (push to ACR, deploy to AKS, access Key Vault secrets)
module "identity_microservices" {
  source              = "./modules/managed-identity"
  name                = var.identity_microservices_name
  resource_group_name = var.resource_group_name
  location            = var.location

  roles = [
    { name = "Azure Kubernetes Service Cluster User Role", scope = module.kubernetes.id },
    { name = "Key Vault Secrets User", scope = module.keyvault.id },
    { name = "AcrPush", scope = module.acr.id },
  ]
}

# Identity for automatic deployment of resources in the shared infrastructure repo
# TODO
