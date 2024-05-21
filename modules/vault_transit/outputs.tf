output "namespace" {
  description = "Namespace in which the Transit engine is mounted (relative to the provider)"
  value       = var.namespace
}

output "mount_path" {
  description = "Mount path for the Transit mount"
  value       = vault_mount.transit.path
}
