variable "name" {
  description = "The name of the PostgreSQL flexible server."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the PostgreSQL flexible server."
  type        = string
}

variable "location" {
  description = "The Azure region where the PostgreSQL flexible server will be created."
  type        = string
}

variable "pg_version" {
  description = "The version of the PostgreSQL flexible server."
  default     = "16"
}

variable "sku" {
  description = "The SKU name for the PostgreSQL flexible server."
  default     = "B_Standard_B1ms"
}

variable "storage_mb" {
  description = "The storage size in MB for the PostgreSQL flexible server. Must be a power of 2."
  default     = 32768
}

variable "storage_tier" {
  description = "The storage tier for the PostgreSQL flexible server."
  default     = null
  type        = string
}

variable "administrator_login" {
  description = "Username of the administrator. If not specified, a random username will be generated."
  type        = string
  default     = null
}

variable "administrator_password" {
  description = "The password associated with the administrator login. If not specified, a random password will be generated."
  type        = string
  default     = null
}
