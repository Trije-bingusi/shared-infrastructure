# Shared infrastructure
# This Azure Container Registry is used by both dev and prod environments

module "acr" {
  source              = "../../modules/acr"
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.acr_name
  sku                 = var.acr_sku
}
