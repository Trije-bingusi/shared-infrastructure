variable "name" {
  description = "Name of the Azure Container Registry."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the ACR."
  type        = string
}

variable "location" {
  description = "The Azure region where the ACR will be created."
  type        = string
}

variable "sku" {
  description = "The SKU of the Azure Container Registry."
  type        = string
  default     = "Basic"
}

variable "admin_enabled" {
  description = "Specifies whether the admin user is enabled."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed for the registry."
  type        = bool
  default     = true
}

