##########################################################################
# 4. Predefined Initiatives Deployments
##########################################################################

data "azurerm_policy_set_definition" "predef-init-data" {
  for_each     = var.predefined_initiatives
  display_name = each.value.initiative_name
}

resource "azurerm_management_group_policy_assignment" "predef-init-assign" {
  for_each             = var.predefined_initiatives
  name                 = "amgpa-${each.key}"
  display_name         = each.value.initiative_name
  policy_definition_id = data.azurerm_policy_set_definition.predef-init-data[each.key].id
  management_group_id  = var.management_group_id
  not_scopes           = lookup(var.initiatives_parameters.category_exclusive_parameters, (jsondecode(data.azurerm_policy_set_definition.predef-init-data[each.key].metadata)).category, null) == null ? var.initiatives_parameters.excluded_scopes : (lookup(var.initiatives_parameters.category_exclusive_parameters, (jsondecode(data.azurerm_policy_set_definition.predef-init-data[each.key].metadata)).category)).excluded_scopes
  enforce              = lookup(var.initiatives_parameters.category_exclusive_parameters, (jsondecode(data.azurerm_policy_set_definition.predef-init-data[each.key].metadata)).category, null) == null ? true : (lookup(var.initiatives_parameters.category_exclusive_parameters, (jsondecode(data.azurerm_policy_set_definition.predef-init-data[each.key].metadata)).category)).enforce
  non_compliance_message {
    content = var.initiatives_parameters.default_policies_non_compliant_message
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

resource "azurerm_management_group_policy_exemption" "predef-init-exemp" {
  /*
  count = (
    var.enable_azure_security_benchmark == null ? 0 : (
      length(lookup(var.enable_azure_security_benchmark, "exemption_reference_list", [])) <= 0 ? 0 : 1
    )
  ) # && length(lookup(var.enable_azure_security_benchmark, "exemption_reference_list", []))) ? 1 : 0
  */
  for_each = {
    for k, obj in var.predefined_initiatives : k => obj if(obj.exemption_reference_list == null ? 0 : length(obj.exemption_reference_list)) > 0
  }
  name                            = "amgpe-${each.key}"
  management_group_id             = var.management_group_id
  policy_assignment_id            = azurerm_management_group_policy_assignment.predef-init-assign[each.key].id
  exemption_category              = "Mitigated"
  policy_definition_reference_ids = each.value.exemption_reference_list
  description                     = "Exemption for ${each.value.initiative_name}"
  display_name                    = "${each.value.initiative_name} - Exemption"
}