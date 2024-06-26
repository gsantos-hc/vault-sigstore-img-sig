variable "namespace" {
  description = "Vault Namespace in which to deploy resources"
  type        = string
  default     = null
}

variable "mount_path" {
  description = "Mount path for container signing Transit secrets"
  type        = string
  default     = "sigstore"
}

variable "key_type" {
  description = "Type of Vault Transit key to use for all signing and verification operations. Refer to Vault API docs for types of keys."
  type        = string
  default     = "ecdsa-p384"

  validation {
    condition     = startswith(var.key_type, "rsa-") || startswith(var.key_type, "ecdsa-") || var.key_type == "ed25519"
    error_message = "Sigstore supports asymmetric keys only."
  }
}

variable "allow_deletion" {
  description = "If true, Transit keys may be deleted. Use with caution!"
  type        = bool
  default     = false
}

variable "team_names" {
  description = "List of application team names for which to create Transit keys"
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for name in var.team_names : can(regex("^[a-z0-9-]+$", name))])
    error_message = "Team names must include only lowercase alphanumeric characters and hyphens."
  }
}

variable "team_members" {
  description = "Map of group membership for each team"
  default     = {}
  type = map(object({
    entity_ids = optional(set(string))
    group_ids  = optional(set(string))
  }))
}
