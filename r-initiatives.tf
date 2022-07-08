##########################################################################
# 1. Initiatives definition and Assignments
##########################################################################

resource "azurerm_policy_set_definition" "general-plcset-def" {
  for_each = {
    for category in local.category_full_list : "${category}" => null
  }
  name                = "azged-${each.key}"
  policy_type         = "Custom"
  display_name        = "${var.initiatives_parameters.display_name_prefix} ${each.key}"
  description         = var.initiatives_parameters.description
  management_group_id = var.management_group_id

  metadata = jsonencode(
    {
      version  = "1.0.0",
      category = "${each.key}"
    }
  )

  dynamic "policy_definition_reference" {
    for_each = {
      for k, plc in local.enforced_policies_plus_addition : k => plc if plc.category == each.key
    }
    iterator = definition
    content {
      policy_definition_id = definition.value.policy_definition_id
      reference_id         = "az-plcset-general-def-${definition.value.name}"
      parameter_values     = lookup(var.custom_policy_parameters, definition.key, null)
    }
  }
}

resource "azurerm_management_group_policy_assignment" "general-plcset-assign" {
  for_each = {
    for category in local.category_full_list : "${category}" => null
  }
  name                 = "azgea-${each.key}"
  display_name         = "${var.initiatives_parameters.display_name_prefix} ${each.key}"
  policy_definition_id = azurerm_policy_set_definition.general-plcset-def[each.key].id
  management_group_id  = var.management_group_id
  not_scopes           = var.initiatives_parameters.excluded_scopes

  dynamic "non_compliance_message" {
    for_each = {
      for k, plc in local.enforced_policies_plus_addition : k => plc if plc.category == each.key
    }
    iterator = definition
    content {
      content                        = lookup(var.custom_policy_non_compliance_messages, definition.key, var.initiatives_parameters.default_policies_non_compliant_message)
      policy_definition_reference_id = "az-plcset-general-def-${definition.value.name}"
    }
  }

  dynamic "identity" {
    for_each = var.initiatives_parameters.identity != null ? ["fake"] : []
    content {
      type         = var.initiatives_parameters.identity.type
      identity_ids = var.initiatives_parameters.identity.type == "UserAssigned" ? var.initiatives_parameters.identity.identity_ids : null
    }
  }
  location = var.location
}
