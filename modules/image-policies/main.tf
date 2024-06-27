terraform {
  required_version = ">= 1.4"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13.2"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.1"
    }

    time = {
      source  = "hashicorp/time"
      version = ">= 0.11.2"
    }
  }
}

# Deploy ClusterImagePolicies via Helm chart to work around a limitation in the
# Terraform provider for Kubernetes: https://github.com/hashicorp/terraform-provider-kubernetes/issues/1367
resource "helm_release" "policies" {
  namespace = var.namespace
  name      = "cluster-image-policies"
  chart     = "${path.module}/chart"
  version   = "1.0.0-${time_static.chart_manifest.unix}"
  depends_on = [
    local_file.chart_manifest,
    local_file.policies,
  ]
}

resource "local_file" "chart_manifest" {
  filename = "${path.module}/chart/Chart.yaml"
  content = templatefile("${path.module}/Chart.yaml.tpl", {
    timestamp = time_static.chart_manifest.unix
  })
}

resource "time_static" "chart_manifest" {
  triggers = {
    cluster_image_policies = terraform_data.policies.id
  }
}

resource "terraform_data" "policies" {
  input = {
    for id, policy in local_file.policies : id => policy.id # SHA1 only to monitor changes
  }
}

resource "local_file" "policies" {
  for_each = var.image_signers
  filename = "${path.module}/chart/templates/${each.key}.yaml"
  content = templatefile("${path.module}/policy.yaml.tpl", {
    policy_name              = each.key
    authority_name           = each.key
    authority_key_identifier = each.value.key_identifier
    image_pattern            = each.value.image_pattern
    enforcement_mode         = each.value.enforce ? "enforce" : "warn"
  })
}
