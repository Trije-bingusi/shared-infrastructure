# General resource settings
variable "resource_group_name" {
  description = "Name of the resource group for shared resources."
  type        = string
}

variable "location" {
  description = "Azure region where shared resources will be created."
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
