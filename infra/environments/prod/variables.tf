# General resource settings
variable "resource_group_name" {
  description = "Name of the resource group which will be used to provision resources."
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created."
  type        = string
}

# Shared ACR reference
variable "acr_name" {
  description = "Name of the existing Azure Container Registry (from shared infrastructure)."
  type        = string
}

# Postgres server
variable "pg_name" {
  description = "The name of the PostgreSQL flexible server."
  type        = string
}

variable "pg_version" {
  description = "The version of the PostgreSQL flexible server."
  type        = string
  default     = "17"
}

variable "pg_sku" {
  description = "The SKU name for the PostgreSQL flexible server."
  type        = string
  default     = "Standard_B1ms"
}

variable "pg_storage_mb" {
  description = "The storage size in MB for the PostgreSQL flexible server. Must be a power of 2."
  type        = number
  default     = 32768
}

variable "pg_location" {
  description = "The Azure region where the PostgreSQL flexible server will be created. If not specified, the resource group location will be used."
  type        = string
  default     = null
}

# Kubernetes service
variable "aks_name" {
  description = "Name of the Azure Kubernetes Service cluster."
  type        = string
}

variable "aks_node_count" {
  description = "Number of nodes in the Azure Kubernetes Service cluster."
  type        = number
  default     = 2
}

variable "aks_node_vm_size" {
  description = "The size of the virtual machines in the Azure Kubernetes Service cluster."
  type        = string
  default     = "Standard_B2pls_v2"
}

variable "aks_location" {
  description = "The Azure region where the AKS cluster will be created. If not specified, the resource group location will be used."
  type        = string
  default     = null
}

# Key Vault for centralized access to resources
variable "keyvault_name" {
  description = "Name of the Azure Key Vault to store shared resource information."
  type        = string
}

# Managed Identities for GitHub actions
variable "identity_microservices_name" {
  description = "Name of the managed identity for microservices."
  type        = string
}
