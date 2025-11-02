variable "resource_group_name" {
  description = "Name of the resource group which will be used to provision resources."
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created."
  type        = string
}

variable "acr_name" {
  description = "Name of the Azure Container Registry."
  type        = string
}

variable "acr_sku" {
  description = "SKU for the Azure Container Registry."
  type        = string
  default     = "Basic"
}
