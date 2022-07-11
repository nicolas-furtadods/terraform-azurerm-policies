##########################################################################
# 5. Guest Policies
##########################################################################

### Data
data "azurerm_policy_set_definition" "azguestconfinit_def" {
  display_name = local.azguestconfinit_name
}

data "azurerm_policy_definition" "addtag-vm" {
  display_name = local.azguestconfinitaddtag-vm_name
}

### Definitions
resource "azurerm_policy_definition" "guestconf-addvmtag" {
  name                = "apd-${local.azguestconfplname}"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Add the tag ${local.azguestconfplname} on virtual machines"
  description         = data.azurerm_policy_definition.addtag-vm.description
  management_group_id = var.management_group_id

  metadata = data.azurerm_policy_definition.addtag-vm.metadata
  policy_rule = jsonencode(
    {
      if = {
        allOf = [
          {
            field  = "type",
            equals = "Microsoft.Compute/virtualMachines"
          },
          {
            field  = "tags['${local.azguestconfplname}']",
            exists = false
          }
        ]
      },
      then = {
        effect = "modify"
        details = {
          roleDefinitionIds = [
            "/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
          ],
          operations = [{
            operation = "add",
            field     = "tags['${local.azguestconfplname}']",
            value     = "TRUE"
            }
          ]
        }
      }
    }
  )
}

### Sets

resource "azurerm_policy_set_definition" "guestconf-plcset-def" {

  name                = "apsd-guest-def"
  policy_type         = "Custom"
  display_name        = "${var.initiatives_parameters.display_name_prefix} Guest Configuration"
  description         = var.initiatives_parameters.description
  management_group_id = var.governed_management_group_id

  metadata = jsonencode(
    {
      version  = "1.0.0",
      category = "Guest Configuration"
    }
  )

  dynamic "policy_definition_reference" {
    for_each = {
      for k, plc in local.guest_configuration_enforced_policies_plus_addition : k => plc
    }
    iterator = definition
    content {
      policy_definition_id = definition.value.policyDefinitionId
      reference_id         = "az-plcset-guestconf-def-${definition.value.name}"
      parameter_values     = definition.value.parameters == "" ? null : definition.value.parameters
    }
  }
}

### Assignments
resource "azurerm_management_group_policy_assignment" "az_guestconf_assign" {
  name                 = "amgpa-gconfassign"
  display_name         = local.azguestconfinit_name
  policy_definition_id = data.azurerm_policy_set_definition.azguestconfinit_def.id
  management_group_id  = var.governed_management_group_id
  not_scopes           = var.guest_configuration_excluded_scopes
  enforce              = var.guest_configuration_enforcement
  non_compliance_message {
    content = "Your deployment is not compliant regarding Azure Policies. Please check the error for investigation, and contact Azure Admins/CloudOps for more information."
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.mi-plc.id]
  }
  location = var.location
}

resource "azurerm_management_group_policy_assignment" "guestconf-plcset-assign" {
  name                 = "amgpa-guest-assign"
  display_name         = "${local.azplcprefix} Guest Configuration ${local.azplcsuffix}"
  policy_definition_id = azurerm_policy_set_definition.guestconf-plcset-def.id
  management_group_id  = var.governed_management_group_id
  not_scopes           = local.guests_not_scopes

  dynamic "non_compliance_message" {
    for_each = {
      for k, plc in local.guest_configuration_enforced_policies_plus_addition : k => plc if plc.require_non_compliance_mesage
    }
    iterator = definition
    content {
      content                        = definition.value.non_compliance_message == null ? var.default_policies_non_compliant_message : definition.value.non_compliance_message
      policy_definition_reference_id = "az-plcset-guestconf-def-${definition.value.name}"
    }
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.mi-plc.id]
  }
  location = var.location
}