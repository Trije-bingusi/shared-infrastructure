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

# Managed Identity for GitHub actions
identity_github_name = "identity-gh-microservices-prod"
identity_github_repos = [
  "repo:Trije-bingusi/svc-courses:environment:prod",
  "repo:Trije-bingusi/svc-notes:environment:prod",
  "repo:Trije-bingusi/svc-users:environment:prod",
  "repo:Trije-bingusi/svc-gateway:environment:prod"
  # Add more repositories as needed
]
