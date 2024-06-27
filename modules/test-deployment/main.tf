terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.30.0"
    }
  }
}

locals {
  deployment_labels = {
    "app.kubernetes.io/name"       = "test-app"
    "app.kubernetes.io/part-of"    = var.deployment_name
    "app.kubernetes.io/managed-by" = "terraform"
  }
}

resource "kubernetes_namespace" "this" {
  metadata {
    name   = var.namespace
    labels = var.namespace_labels
  }
}

resource "kubernetes_deployment" "this" {
  metadata {
    name      = var.deployment_name
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = local.deployment_labels
    }

    template {
      metadata {
        name   = var.deployment_name
        labels = local.deployment_labels
      }

      spec {
        termination_grace_period_seconds = 1
        container {
          name    = "test-app"
          image   = var.image
          command = ["sleep", "1000"]
        }
      }
    }
  }
}
