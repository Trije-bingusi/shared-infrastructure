# Infrastructure configuration for the "dev" environment
resource_group_name = "rso-dev-rg"
location            = "Germany West Central"

# Reference shared ACR
acr_name = "rsobingusiacr"

# PostgreSQL server
pg_name       = "rsobingusipgsdev"
pg_version    = "16"
pg_sku        = "B_Standard_B1ms"
pg_storage_mb = 32768
pg_location   = "Switzerland North"

# Kubernetes cluster
aks_name         = "rsobingusiaksdev"
aks_node_count   = 2
aks_node_vm_size = "Standard_B2als_v2"
aks_location     = "Switzerland North"

# Key Vault
keyvault_name = "rsobingusivaultdev"

# Managed Identity for GitHub actions
identity_github_name = "identity-gh-microservices-dev"
identity_github_repos = [
  "repo:Trije-bingusi/svc-courses:environment:dev",
  "repo:Trije-bingusi/svc-notes:environment:dev",
  "repo:Trije-bingusi/svc-users:environment:dev",
  "repo:Trije-bingusi/svc-gateway:environment:dev",
  "repo:Trije-bingusi/svc-transcription:environment:dev",
  "repo:Trije-bingusi/svc-video:environment:dev",
  "repo:Trije-bingusi/svc-summary:environment:dev",
  # Add more repositories as needed
]

# Kubernetes config
k8s_namespace         = "rso"
k8s_db_secret_name    = "db-connection-url"
