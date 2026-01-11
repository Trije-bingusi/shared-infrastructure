variable "namespace" {
  description = "Namespace for Loki and Promtail"
  type        = string
  default     = "monitoring"
}

variable "loki_release_name" {
  type    = string
  default = "loki"
}

variable "promtail_release_name" {
  type    = string
  default = "promtail"
}

variable "loki_chart_version" {
  type    = string
  default = "6.6.2"
}

variable "promtail_chart_version" {
  type    = string
  default = "6.15.5"
}

variable "retention" {
  description = "Log retention period (e.g. 7d, 30d)"
  type        = string
  default     = "7d"
}

variable "requests_cpu" {
  type    = string
  default = "100m"
}

variable "requests_memory" {
  type    = string
  default = "128Mi"
}

variable "limits_cpu" {
  type    = string
  default = "300m"
}

variable "limits_memory" {
  type    = string
  default = "512Mi"
}
