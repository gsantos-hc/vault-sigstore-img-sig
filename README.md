# Container image signing with HashiCorp Vault and Sigstore Policy Controller

Sample Terraform module to demonstrate using
[HashiCorp Vault](https://www.vaultproject.io)'s
[Transit Engine](https://developer.hashicorp.com/vault/tutorials/encryption-as-a-service/eaas-transit)
to sign and verify container images and the
[Sigstore Kubernetes Policy Controller](https://docs.sigstore.dev/policy-controller/overview/)
to enforce a container image signing policy in a Kubernetes cluster.

## Disclaimer

This module is intended only for demo purposes and should not be used in a
production environment without careful consideration of applicable operational
and security requirements.

## Pre-Requisites

- HashiCorp Vault cluster (e.g.,
  [HCP Vault Dedicated](https://www.hashicorp.com/cloud))
- [Kubernetes Authentication](https://developer.hashicorp.com/vault/docs/auth/kubernetes)
  configured in the Vault cluster
- Authentication role pre-provisioned for the Sigstore Policy Controller to
  authenticate to Vault, e.g. restricting access to the `sigstore` namespace and
  the `sigstore-policy-controller-webhook` Service Account.

## Test Deployment

Once you have signed a test container image, redeploy the Terraform root module
with the `image_name` and `image_digest` variables set. The Terraform root
module will then attempt to create a Kubernetes deployment to run the specified
container image and validate that Sigstore Policy Controller is enforcing the
container image signing policy.

<!-- prettier-ignore-start -->
<!-- BEGIN_TF_DOCS -->


## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_harbor"></a> [harbor](#module\_harbor) | ./modules/harbor | n/a |
| <a name="module_image_policies"></a> [image\_policies](#module\_image\_policies) | ./modules/image-policies | n/a |
| <a name="module_policy_controller"></a> [policy\_controller](#module\_policy\_controller) | ./modules/policy-controller | n/a |
| <a name="module_test_deployment"></a> [test\_deployment](#module\_test\_deployment) | ./modules/test-deployment | n/a |
| <a name="module_vault_transit"></a> [vault\_transit](#module\_vault\_transit) | ./modules/vault-transit | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deploy_harbor"></a> [deploy\_harbor](#input\_deploy\_harbor) | Toggle to deploy an instance of the Harbor registry in the cluster | `bool` | `false` | no |
| <a name="input_image_digest"></a> [image\_digest](#input\_image\_digest) | SHA256 digest of the test container image (prefixed with sha256:) | `string` | `null` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | Name of the container image to use for testing policy enforcement | `string` | `"library/busybox"` | no |
<!-- END_TF_DOCS -->
<!-- prettier-ignore-end -->
