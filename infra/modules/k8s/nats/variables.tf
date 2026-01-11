variable "release_name" {
  description = "Helm release name for NATS"
  type        = string
  default     = "nats"
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "nats"
}

variable "chart_version" {
  description = "Helm chart version"
  type        = string
  default     = "0.19.1"
}

variable "replicas" {
  description = "Number of NATS pods"
  type        = number
  default     = 3
}

variable "jetstream" {
  description = "Enable JetStream"
  type        = bool
  default     = true
}

variable "persistence" {
  description = "Enable persistent storage for NATS"
  type        = bool
  default     = true
}

variable "storage_size" {
  description = "Size of persistent volume"
  type        = string
  default     = "5Gi"
}

variable "memory_request" {
  description = "Memory request"
  type        = string
  default     = "256Mi"
}

variable "cpu_request" {
  description = "CPU request"
  type        = string
  default     = "100m"
}

variable "memory_limit" {
  description = "Memory limit"
  type        = string
  default     = "512Mi"
}

variable "cpu_limit" {
  description = "CPU limit"
  type        = string
  default     = "250m"
}
