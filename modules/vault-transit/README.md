# Vault Module

Configures a Transit engine and asymmetric key pair in Vault for signing and
verifying container images, as well as corresponding Identity Groups and ACL
Policies.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >= 4.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_vault"></a> [vault](#provider\_vault) | >= 4.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [vault_identity_group.app_team](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_group) | resource |
| [vault_identity_group.verifiers](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_group) | resource |
| [vault_mount.transit](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/mount) | resource |
| [vault_policy.app_team](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |
| [vault_policy.verify](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |
| [vault_transit_secret_backend_key.app_team](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/transit_secret_backend_key) | resource |
| [vault_policy_document.app_team](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/policy_document) | data source |
| [vault_policy_document.verify](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_deletion"></a> [allow\_deletion](#input\_allow\_deletion) | If true, Transit keys may be deleted. Use with caution! | `bool` | `false` | no |
| <a name="input_key_type"></a> [key\_type](#input\_key\_type) | Type of Vault Transit key to use for all signing and verification operations. Refer to Vault API docs for types of keys. | `string` | `"ecdsa-p384"` | no |
| <a name="input_mount_path"></a> [mount\_path](#input\_mount\_path) | Mount path for container signing Transit secrets | `string` | `"sigstore"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Vault Namespace in which to deploy resources | `string` | `""` | no |
| <a name="input_team_members"></a> [team\_members](#input\_team\_members) | Map of group membership for each team | <pre>map(object({<br>    entity_ids = optional(set(string))<br>    group_ids  = optional(set(string))<br>  }))</pre> | `{}` | no |
| <a name="input_team_names"></a> [team\_names](#input\_team\_names) | List of application team names for which to create Transit keys | `set(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_mount_path"></a> [mount\_path](#output\_mount\_path) | Mount path for the Transit mount |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace in which the Transit engine is mounted |
| <a name="output_public_keys"></a> [public\_keys](#output\_public\_keys) | Public signature-verification keys |
<!-- END_TF_DOCS -->
