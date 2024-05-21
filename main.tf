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
