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
      for k, plc in local.enforced_policies : k => plc if plc.category == each.key
    }
    iterator = definition
    content {
      policy_definition_id = definition.value.policy_definition_id
      reference_id         = "az-plcset-general-def-${definition.key}"
      parameter_values     = definition.value.parameters # This is validated in local so no need to check null
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
      for k, plc in local.enforced_policies : k => plc if plc.category == each.key && (plc.category == "Indexed" || plc.category == "All")
    }
    iterator = definition
    content {
      content                        = definition.value.non_compliance_message # This is validated in local so no need to check null
      policy_definition_reference_id = "az-plcset-general-def-${definition.key}"
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
