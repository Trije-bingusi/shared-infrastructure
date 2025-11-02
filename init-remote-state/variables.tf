variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group in which the storage account for remote state will be created."
  type        = string
}

variable "storage_account_name" {
  description = "The name of the provisioned storage account to hold the Terraform state file. If not provided, a random name will be generated."
  type        = string
  default     = ""
}

variable "storage_container_name" {
  description = "The name of the provisioned storage container to hold the Terraform state file."
  default     = "tfstate"
  type        = string
}

