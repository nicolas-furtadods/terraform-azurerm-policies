locals {
  ##########################################################################
  # 1. Initiatives definition and Assignments
  ##########################################################################
  category_full_list = distinct(concat(local.category_list_custom_policies, local.category_list_predefined_policies))

  enforced_policies = merge(local.custom_policies, local.predefined_policies)

  ##########################################################################
  # 2. Custom Policies
  ##########################################################################

  library_folder = lookup(var.custom_policy, "library_folder", ".")
  policy_files   = fileset(local.library_folder, "*.json")
  raw_data       = [for f in local.policy_files : jsondecode(file("${local.library_folder}/${f}"))]
  policies = {
    for f in local.raw_data : f.name => f
  }

  category_list_custom_policies = distinct(flatten([
    for policykey, plc in module.custom_policy : plc.category
  ]))

  custom_policies = tomap({
    for key, policy in module.custom_policy :
    key => {
      name                   = policy.name,
      display_name           = policy.display_name,
      policy_definition_id   = policy.policy_definition_id
      category               = policy.category
      parameters             = lookup(var.custom_policy.policy_exclusive_parameters, key, null) == null ? null : (lookup(var.custom_policy.policy_exclusive_parameters, key)).parameter_values
      non_compliance_message = lookup(var.custom_policy.policy_exclusive_parameters, key, null) == null ? null : (lookup(var.custom_policy.policy_exclusive_parameters, key)).non_compliance_message
    }
  })

  ##########################################################################
  # 3. Enforce existing policies
  ##########################################################################
  category_list_predefined_policies = distinct(flatten([
    for policyname, plc in var.predefined_policies : plc.category
  ]))

  policyDefinitionPrefix = "/providers/Microsoft.Authorization/policyDefinitions/"

  predefined_policies = tomap({
    for key, policy in var.predefined_policies :
    key => {
      name                   = policy.name,
      display_name           = policy.display_name,
      policy_definition_id   = "${local.policyDefinitionPrefix}${policy.name}"
      category               = policy.category
      parameters             = policy.parameters
      non_compliance_message = policy.non_compliance_message == null ? var.initiatives_parameters.default_policies_non_compliant_message : policy.non_compliance_message
    }
  })

  ##########################################################################
  # 4. Predefined Initiatives Deployments
  ##########################################################################
}

