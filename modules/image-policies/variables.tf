variable "namespace" {
  description = "Kubernetes namespace in which to deploy the Helm chart with the policies"
  type        = string
}

variable "image_signers" {
  type = map(object({
    image_pattern  = string
    key_identifier = string
    enforce        = optional(bool, true)
  }))
}
