resource "azurerm_policy_definition" "im_caf_policies" {
  name                = var.name
  policy_type         = "Custom"
  mode                = var.mode
  display_name        = var.display_name
  description         = var.description
  metadata            = var.metadata
  parameters          = var.parameters
  policy_rule         = var.rule
  management_group_id = var.management_group_id

}