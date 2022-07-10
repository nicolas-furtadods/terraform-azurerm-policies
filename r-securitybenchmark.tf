data "azurerm_policy_set_definition" "azsecurity_def" {
  count        = var.enable_azure_security_benchmark == null ? 0 : 1
  display_name = local.azsecurity_name
}

resource "azurerm_management_group_policy_assignment" "az_security_assign" {
  count                = var.enable_azure_security_benchmark == null ? 0 : 1
  name                 = "amgpa-securityben"
  display_name         = local.azsecurity_name
  policy_definition_id = data.azurerm_policy_set_definition.azsecurity_def[0].id
  management_group_id  = var.management_group_id
  not_scopes           = var.initiatives_parameters.excluded_scopes
  non_compliance_message {
    content = var.initiatives_parameters.default_policies_non_compliant_message
  }
}

resource "azurerm_management_group_policy_exemption" "az_security_exemption" {
  count = (
    var.enable_azure_security_benchmark == null ? 0 : (
      length(lookup(var.enable_azure_security_benchmark, "exemption_reference_list", [])) <= 0 ? 0 : 1
    )
  ) # && length(lookup(var.enable_azure_security_benchmark, "exemption_reference_list", []))) ? 1 : 0
  name                            = "amgpae_securityben"
  management_group_id             = var.management_group_id
  policy_assignment_id            = azurerm_management_group_policy_assignment.az_security_assign[0].id
  exemption_category              = "Mitigated"
  policy_definition_reference_ids = var.enable_azure_security_benchmark.exemption_reference_list
  description                     = "Exemption for ${local.azsecurity_name}"
  display_name                    = "${local.azsecurity_name} - Exemption"
}