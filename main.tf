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
  source     = "./modules/vault_transit"
  team_names = ["app-team-a", "app-team-b"]
  team_members = {
    app-team-a = {
      entity_ids = [
        "ab86f1ef-9b2b-8e8d-55af-10935b083fa5", # Alice
      ]
    }
  }
}

# Optional: Harbor Registry ----------------------------------------------------
# Default username and password for Harbor is "admin" and "Harbor12345"
module "harbor" {
  count        = var.deploy_harbor ? 1 : 0
  source       = "./modules/harbor"
  namespace    = "harbor"
  external_url = "harbor.harbor.svc"
}
