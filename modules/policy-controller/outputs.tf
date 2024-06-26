output "opt_in" {
  description = "Whether policy enforcement is opt-in only"
  value       = var.opt_in
}

output "opt_in_label" {
  description = "If policy enforcement is opt-in only, the label that must be associated with opted-in namespaces"
  value       = var.opt_in ? var.opt_in_label : null
}

output "opt_out_label" {
  description = "If policy enforcement is opt-out, the label that must be associated with opted-out namespaces"
  value       = !var.opt_in ? var.opt_out_label : null
}
