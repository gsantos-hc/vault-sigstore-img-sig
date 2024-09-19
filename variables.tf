variable "image_name" {
  description = "Name of the container image to use for testing policy enforcement"
  type        = string
  default     = "library/busybox"
}

variable "image_digest" {
  description = "SHA256 digest of the test container image (prefixed with sha256:)"
  type        = string
  default     = null
}

variable "deploy_harbor" {
  description = "Toggle to deploy an instance of the Harbor registry in the cluster"
  type        = bool
  default     = false
}
