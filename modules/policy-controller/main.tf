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

  vault_sidecar_annotations = {
    agent-inject    = "true"
    agent-configmap = kubernetes_config_map.vault_proxy.metadata[0].name
  }
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

        env = {
          VAULT_ADDR                 = "http://127.0.0.1:8210" # Sidecar proxy address
          VAULT_TOKEN                = "ignore"
          VAULT_TLS_SKIP_VERIFY      = "true"
          TRANSIT_SECRET_ENGINE_PATH = "${var.vault_transit_path}"
        }

        podAnnotations = {
          for key, value in local.vault_sidecar_annotations : "vault.hashicorp.com/${key}" => value
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

# Vault Sidecar Configuration --------------------------------------------------
resource "kubernetes_config_map" "vault_proxy" {
  metadata {
    name      = "vault-proxy-config"
    namespace = var.namespace
  }

  data = {
    "config.hcl" = <<EOF
vault {
  address = "${var.vault_addr}"
}

auto_auth {
  method {
    type       = "kubernetes"
    mount_path = "${var.vault_auth_mount}"
    namespace  = "${var.vault_auth_namespace}"
    config {
      role = "${var.vault_auth_role}"
    }
  }
}

api_proxy {
  use_auto_auth_token = "force"
}

listener "tcp" {
  address     = "127.0.0.1:8210"
  tls_disable = true
}

cache {}
EOF

    "config-init.hcl" = <<EOF
exit_after_auth = true

vault {
  address = "${var.vault_addr}"
}

auto_auth {
  method {
    type       = "kubernetes"
    mount_path = "${var.vault_auth_mount}"
    namespace  = "${var.vault_auth_namespace}"
    config {
      role = "${var.vault_auth_role}"
    }
  }
}

api_proxy {
  use_auto_auth_token = "force"
}

listener "tcp" {
  address     = "127.0.0.1:8210"
  tls_disable = true
}
EOF
  }
}
