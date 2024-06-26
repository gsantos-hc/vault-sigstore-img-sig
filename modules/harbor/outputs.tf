output "internal_url" {
  value = local.internal_url
}

output "external_url" {
  value = var.external_url
}

output "tls_cert" {
  description = "TLS certificate for Harbor registry"
  value       = tls_self_signed_cert.harbor.cert_pem
}
