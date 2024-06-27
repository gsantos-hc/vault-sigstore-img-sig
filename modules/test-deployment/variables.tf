variable "namespace" {
  description = "Kubernetes namespace to create for policy enforcement test"
  type        = string
}

variable "namespace_labels" {
  description = "Labels to attach to test namespace"
  type        = map(string)
}

variable "deployment_name" {
  description = "Name of the test deployment"
  type        = string
  default     = "test"
}

variable "image" {
  description = "Container image to use for the test"
  type        = string
}
