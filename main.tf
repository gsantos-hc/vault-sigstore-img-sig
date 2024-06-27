# Provider Configs -------------------------------------------------------------
provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# Vault Transit ----------------------------------------------------------------
module "vault_transit" {
  source     = "./modules/vault-transit"
  team_names = ["app-team-a", "app-team-b"]
  team_members = {
    app-team-a = {
      entity_ids = [
        "ab86f1ef-9b2b-8e8d-55af-10935b083fa5", # Alice
      ]
    }
  }
}

# Sigstore Policy Controller ---------------------------------------------------
module "policy_controller" {
  source        = "./modules/policy-controller"
  namespace     = local.sigstore_namespace
  opt_in        = true # Minimize impact of policy enforcement by opting in namespaces
  opt_in_label  = local.sigstore_opt_in_label
  opt_out_label = local.sigstore_opt_out_label

  # Test deployment of Harbor registry uses self-signed certificate
  registry_ca_certs = try([module.harbor[0].tls_cert], null)
}

# Cluster Image Policies -------------------------------------------------------
module "image_policies" {
  source    = "./modules/image-policies"
  namespace = local.sigstore_namespace
  image_signers = {
    for team, key_name in module.vault_transit.key_names : team => {
      image_pattern  = "${local.registry_prefix}/${team}/**"
      key_identifier = "hashivault://${key_name}"
    }
  }

  depends_on = [
    module.policy_controller,
  ]
}

# Test Namespace & Deployment --------------------------------------------------
module "test_deployment" {
  source           = "./modules/test-deployment"
  namespace        = "test-deployment"
  namespace_labels = { "${local.sigstore_opt_in_label}" = true }
  deployment_name  = "test"
  image            = "${local.registry_prefix}/${var.image_name}@${var.image_digest}"

  depends_on = [
    module.image_policies,
  ]
}

# Optional: Harbor Registry ----------------------------------------------------
# Default username and password for Harbor is "admin" and "Harbor12345"
module "harbor" {
  count        = var.deploy_harbor ? 1 : 0
  source       = "./modules/harbor"
  external_url = "harbor.harbor.svc"
  namespace    = "harbor"
  namespace_labels = {
    "${local.sigstore_opt_out_label}" = true
  }
}

# Locals -----------------------------------------------------------------------
locals {
  # Adjust this to your environment
  registry_prefix = try(module.harbor[0].internal_url, "docker.io")

  sigstore_namespace     = "sigstore"
  sigstore_opt_in_label  = "policy.sigstore.dev/include"
  sigstore_opt_out_label = "policy.sigstore.dev/exclude"
}
