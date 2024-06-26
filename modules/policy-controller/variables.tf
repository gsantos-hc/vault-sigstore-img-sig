variable "namespace" {
  description = "Kubernetes namespace in which to deploy the Sigstore Policy Controller"
  type        = string
  default     = "sigstore"
}

variable "chart_version" {
  description = "Sigstore Policy Controller Helm chart version"
  type        = string
  default     = "0.6.8"
}

variable "opt_in" {
  description = "If true, only namespaces with the `opt_in_label` label set will have policy enforced by the Policy Controller"
  type        = bool
  default     = false
}

variable "opt_in_label" {
  description = "Label name for opting a namespace into Sigstore Policy Controller enforcement, if `opt_in = true`"
  type        = string
  default     = "policy.sigstore.dev/include"
}

variable "opt_out_label" {
  description = "Label name for opting a namespace out of Sigstore Policy Controller enforcement, if `opt_in = false`"
  type        = string
  default     = "policy.sigstore.dev/exclude"
}

variable "registry_ca_certs" {
  description = "List of CA certificates to trust for registry certificates"
  type        = list(string)
  default     = []
}

variable "no_match_policy" {
  description = "What action should the Policy Controller take when no ClusterImagePolicy matches the image (warn|allow|deny)"
  type        = string
  default     = "deny"

  validation {
    condition     = contains(["warn", "allow", "deny"], var.no_match_policy)
    error_message = "Policy must be one of 'warn', 'allow', or 'deny'."
  }
}
