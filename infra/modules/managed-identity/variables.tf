variable "name" {
  description = "Name of the Managed Identity."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the AKS."
  type        = string
}

variable "location" {
  description = "The Azure region where the AKS will be created."
  type        = string
}

variable "roles" {
  description = "A list of role definitions to assign to the Managed Identity."
  type = list(object({
    name  = string
    scope = string
  }))
}

variable "github_federated_identity" {
  description = "Configuration for GitHub OIDC federated identity credential, used for GitHub Actions. If not provided, no federated identity will be created."
  type = object({
    organization = string
    repository   = string
  })
  default = null
}
