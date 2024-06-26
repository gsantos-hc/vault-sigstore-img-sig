variable "namespace" {
  description = "Kubernetes namespace in which to deploy Harbor"
  type        = string
  default     = "harbor"
}

variable "namespace_labels" {
  description = "Map of labels to associate with the Harbor namespace"
  type        = map(string)
  default     = null
}

variable "chart_version" {
  description = "Helm chart version for Harbor to deploy"
  type        = string
  default     = "1.14.2"
}

variable "service_type" {
  description = "Type of service to deploy for Harbor"
  type        = string
  default     = "loadBalancer"
  validation {
    condition     = contains(["ingress", "clusterIP", "loadBalancer", "nodePort"], var.service_type)
    error_message = "Service type must be one of ingress, clusterIP, loadBalancer, or nodePort."
  }
}

variable "external_url" {
  description = "Domain name through which the Harbor registry is accessed"
  type        = string
}
