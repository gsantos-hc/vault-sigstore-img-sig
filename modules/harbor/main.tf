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

    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.5"
    }
  }
}

locals {
  release_name = "harbor"
  internal_url = "${local.release_name}.${var.namespace}.svc"
}

resource "kubernetes_namespace" "harbor" {
  metadata {
    name   = var.namespace
    labels = var.namespace_labels
  }
}

resource "helm_release" "harbor" {
  namespace  = kubernetes_namespace.harbor.metadata[0].name
  name       = local.release_name
  repository = "https://helm.goharbor.io"
  chart      = "harbor"
  version    = var.chart_version

  set {
    name  = "externalURL"
    value = "https://${var.external_url}"
  }

  set {
    name  = "expose.type"
    value = var.service_type
  }

  set {
    name  = "expose.tls.certSource"
    value = "secret"
  }

  set {
    name  = "expose.tls.secret.secretName"
    value = kubernetes_secret.harbor_certificate.metadata[0].name
  }
}

# TLS Certificate for Harbor ---------------------------------------------------
# Not recommended for production!
resource "kubernetes_secret" "harbor_certificate" {
  type = "kubernetes.io/tls"
  metadata {
    name      = "harbor-tls"
    namespace = kubernetes_namespace.harbor.metadata[0].name
  }

  data = {
    "tls.key" = tls_self_signed_cert.harbor.private_key_pem
    "tls.crt" = tls_self_signed_cert.harbor.cert_pem
  }
}

resource "tls_private_key" "harbor" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "harbor" {
  private_key_pem       = tls_private_key.harbor.private_key_pem
  dns_names             = toset([var.external_url, local.internal_url])
  validity_period_hours = 24 * 365
  allowed_uses = [
    # Key Usage
    "digital_signature",
    "key_encipherment",

    # Extended Key Usage
    "server_auth",
  ]
}
