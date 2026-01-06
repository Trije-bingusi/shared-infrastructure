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

variable "github_federated_identity_subjects" {
  description = "List of subjects for GitHub OIDC federated identity credentials, used for GitHub Workflows. Should be in the format 'repo:<organization>/<repository>:<ref>'. You can use '*' as a wildcard for <ref> to allow all branches, environments, and tags."
  type        = list(string)
  default     = []
}
