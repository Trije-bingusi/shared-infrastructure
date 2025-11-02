# General resource settings
variable "resource_group_name" {
  description = "Name of the resource group which will be used to provision resources."
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created."
  type        = string
}

# Container registry
variable "acr_name" {
  description = "Name of the Azure Container Registry."
  type        = string
}

variable "acr_sku" {
  description = "SKU for the Azure Container Registry."
  type        = string
  default     = "Basic"
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
