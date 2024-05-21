# Sample Vault Server configuration for demo purposes only

ui            = true
api_addr      = "http://127.0.0.1:8200"
cluster_addr  = "http://127.0.0.1:8201"
disable_mlock = true

storage "raft" {
  path    = "raft"
  node_id = "local"
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = true
}
