terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 4.2.0"
    }
  }
}

# Transit Engine & Signing Keys ------------------------------------------------
resource "vault_mount" "transit" {
  type                         = "transit"
  namespace                    = var.namespace
  path                         = var.mount_path
  description                  = "Transit keys for signing container images"
  audit_non_hmac_request_keys  = local.non_hmac_request_keys
  audit_non_hmac_response_keys = local.non_hmac_response_keys
}

resource "vault_transit_secret_backend_key" "app_team" {
  for_each         = var.team_names
  namespace        = vault_mount.transit.namespace
  backend          = vault_mount.transit.path
  name             = each.key
  type             = var.key_type
  deletion_allowed = var.allow_deletion
}

# App Team Groups & Policies ---------------------------------------------------
resource "vault_identity_group" "app_team" {
  for_each                   = var.team_names
  namespace                  = vault_mount.transit.namespace
  name                       = "${var.mount_path}-${each.key}"
  policies                   = [vault_policy.app_team[each.key].name]
  member_entity_ids          = try(var.team_members[each.key].entity_ids, null)
  external_member_entity_ids = try(var.team_members[each.key].entity_ids == null, true)
  member_group_ids           = try(var.team_members[each.key].group_ids, null)
  external_member_group_ids  = try(var.team_members[each.key].group_ids == null, true)
}

resource "vault_policy" "app_team" {
  for_each  = var.team_names
  namespace = vault_mount.transit.namespace
  name      = "${var.mount_path}-${each.key}"
  policy    = data.vault_policy_document.app_team[each.key].hcl
}

data "vault_policy_document" "app_team" {
  for_each = var.team_names

  rule {
    description  = "List signing keys (for UI navigation; otherwise not required)"
    path         = "${vault_mount.transit.path}/keys"
    capabilities = ["list"]
  }

  rule {
    description  = "Read signing key metadata and public key"
    path         = "${vault_transit_secret_backend_key.app_team[each.key].backend}/keys/${vault_transit_secret_backend_key.app_team[each.key].name}"
    capabilities = ["read"]
  }

  rule {
    description  = "Generate HMAC signatures"
    path         = "${vault_transit_secret_backend_key.app_team[each.key].backend}/hmac/${vault_transit_secret_backend_key.app_team[each.key].name}"
    capabilities = ["create", "update"]
  }

  rule {
    description  = "Generate HMAC signatures with specified algorithm"
    path         = "${vault_transit_secret_backend_key.app_team[each.key].backend}/hmac/${vault_transit_secret_backend_key.app_team[each.key].name}/+"
    capabilities = ["create", "update"]
  }

  rule {
    description  = "Sign image digests"
    path         = "${vault_transit_secret_backend_key.app_team[each.key].backend}/sign/${vault_transit_secret_backend_key.app_team[each.key].name}"
    capabilities = ["create", "update"]
  }

  rule {
    description  = "Sign image digests with specified algorithm"
    path         = "${vault_transit_secret_backend_key.app_team[each.key].backend}/sign/${vault_transit_secret_backend_key.app_team[each.key].name}/+"
    capabilities = ["create", "update"]
  }

  rule {
    description  = "Verify signatures"
    path         = "${vault_transit_secret_backend_key.app_team[each.key].backend}/verify/${vault_transit_secret_backend_key.app_team[each.key].name}"
    capabilities = ["create", "update"]
  }

  rule {
    description  = "Verify signatures with specified algorithm"
    path         = "${vault_transit_secret_backend_key.app_team[each.key].backend}/verify/${vault_transit_secret_backend_key.app_team[each.key].name}/+"
    capabilities = ["create", "update"]
  }
}

# Verifiers Group & Policy -----------------------------------------------------
resource "vault_identity_group" "verifiers" {
  namespace                  = vault_mount.transit.namespace
  name                       = "${var.mount_path}-verifiers"
  policies                   = [vault_policy.verify.name]
  external_member_entity_ids = true
  external_member_group_ids  = true
}

resource "vault_policy" "verify" {
  namespace = vault_mount.transit.namespace
  name      = "${var.mount_path}-verify"
  policy    = data.vault_policy_document.verify.hcl
}

data "vault_policy_document" "verify" {
  rule {
    description  = "Ready signing key metadata and public key"
    path         = "${vault_mount.transit.path}/keys/*"
    capabilities = ["read"]
  }

  rule {
    description  = "Verify signatures made with any key in the ${var.mount_path} Transit engine"
    path         = "${vault_mount.transit.path}/verify/*"
    capabilities = ["create", "update"]
  }
}

# Locals -----------------------------------------------------------------------
locals {
  # Optional: Record image digests and corresponding signatures in audit logs
  non_hmac_response_keys = ["signature", "valid"]
  non_hmac_request_keys = [
    "batch_input",
    "hash_algorithm",
    "hmac",
    "input",
    "key_version",
    "marshaling_algorithm",
    "name",
    "prehashed",
    "salt_length",
    "signature_algorithm",
    "signature",
  ]
}
