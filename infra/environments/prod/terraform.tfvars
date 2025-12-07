# Infrastructure configuration for the "prod" environment
resource_group_name = "rso-dev-rg"
location            = "Germany West Central"

# Reference shared ACR
acr_name = "rsobingusiacr"

# PostgreSQL server
pg_name       = "rsobingusipgsprod"
pg_version    = "16"
pg_sku        = "B_Standard_B1ms"
pg_storage_mb = 32768
pg_location   = "Switzerland North"

# Kubernetes cluster
aks_name         = "rsobingusiaksprod"
aks_node_count   = 1
aks_node_vm_size = "Standard_B2pls_v2"

# Key Vault
keyvault_name = "rsobingusivaultprod"

# Managed Identities
identity_microservices_name = "identity-gh-microservices-prod"
