output "policy_definition_id" {
  value       = azurerm_policy_definition.im_caf_policies.id
  description = "ID of the created Policy"
}

output "category" {
  value       = (jsondecode(var.metadata)).category
  description = "Category of the created policy."
}

output "name" {
  value       = var.name
  description = "Name of the created policy."
}

output "display_name" {
  value       = var.display_name
  description = "Display Name of the created policy."
}