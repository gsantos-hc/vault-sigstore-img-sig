terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13.2"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.30.0"
    }
  }
}

resource "kubernetes_namespace" "sigstore" {
  metadata {
    name = var.namespace
    labels = {
      "${var.opt_out_label}" = "true"
    }
  }
}

# Helm Chart -------------------------------------------------------------------
locals {
  custom_ca_certs = var.registry_ca_certs != null && length(var.registry_ca_certs) > 0
  values_registry_bundle = local.custom_ca_certs == false ? "{}" : yamlencode({
    webhook = {
      registryCaBundle = {
        name = kubernetes_config_map.ca_bundles.metadata[0].name
        key  = "ca-bundle"
      }
    }
  })
}

resource "helm_release" "policy_controller" {
  namespace  = kubernetes_namespace.sigstore.metadata[0].name
  name       = "sigstore-policy-controller"
  repository = "https://sigstore.github.io/helm-charts"
  chart      = "policy-controller"
  version    = var.chart_version

  values = [
    local.values_registry_bundle,
    yamlencode({
      webhook = {
        configData = {
          no-match-policy = var.no_match_policy
        }

        namespaceSelector = {
          matchExpressions = [
            {
              key      = var.opt_in ? var.opt_in_label : var.opt_out_label
              operator = var.opt_in ? "Exists" : "DoesNotExist"
            }
          ]
        }
      }
    })
  ]
}

# Registry CA Certificates -----------------------------------------------------
resource "kubernetes_config_map" "ca_bundles" {
  metadata {
    name      = "ca-bundle"
    namespace = kubernetes_namespace.sigstore.metadata[0].name
  }

  data = {
    "ca-bundle" = join("\n", var.registry_ca_certs)
  }
}
