# Infrastructure configuration for the "shared" environment
resource_group_name = "rso-dev-rg"
location            = "Germany West Central"

# Shared Azure Container Registry
acr_name = "rsobingusiacr"
acr_sku  = "Basic"