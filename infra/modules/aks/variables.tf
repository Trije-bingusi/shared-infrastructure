variable "name" {
  description = "Name of the Azure Kubernetes Cluster."
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

variable "node_pool_name" {
  description = "Name of the default node pool."
  type        = string
  default     = "default"
}

variable "node_count" {
  description = "Number of nodes in the default node pool."
  type        = number
  default     = 1
}

variable "node_vm_size" {
  description = "The size of the virtual machines in the default node pool."
  type        = string
  default     = "Standard_B2pls_v2"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster. If not specified, it will be generated as a combination of the cluster name and a random suffix."
  type        = string
  default     = null
}

variable "attached_container_registries" {
  description = "List of Azure Container Registry IDs to attach to the AKS cluster."
  type        = list(string)
  default     = []
}
