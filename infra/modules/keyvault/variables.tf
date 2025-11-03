variable "name" {
  description = "Name of the Azure Key Vault."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Key Vault."
  type        = string
}

variable "location" {
  description = "The Azure region where the Key Vault will be created."
  type        = string
}

variable "sku" {
  description = "The SKU name of the Key Vault. Possible values are 'standard' and 'premium'."
  type        = string
  default     = "standard"
}

variable "soft_delete_retention_days" {
  description = "The number of days that deleted Key Vaults are retained. Default is 7 days."
  type        = number
  default     = 7
}

variable "enable_rbac_authorization" {
  description = "Specifies whether to enable RBAC authorization for the Key Vault. Default is true."
  type        = bool
  default     = true
}

variable "secrets" {
  description = "A map of secrets to store in the Key Vault. The key is the name of the secret, and the value is the value of the secret."
  type        = map(string)
  default     = {}
}

variable "assign_kv_role" {
  description = "Specifies whether to assign the Key Vault Secrets Officer role to the current principal. Default is true."
  type        = bool
  default     = true
}
