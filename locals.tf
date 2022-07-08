locals {
  ##########################################################################
  # 1. Initiatives definition and Assignments
  ##########################################################################
  category_list_custom_policies = distinct(flatten([
    for policykey, plc in module.custom_policy : plc.category
  ]))

  category_full_list = local.category_list_custom_policies

  enforced_policies_plus_addition = tomap({
    for key, policy in module.custom_policy :
    key => {
      name                 = policy.name,
      display_name         = policy.display_name,
      policy_definition_id = policy.policy_definition_id
      category             = policy.category
    }
  })

  ##########################################################################
  # 2. Custom Policies
  ##########################################################################

  library_folder = lookup(var.custom_policy, "library_folder", ".")
  policy_files   = fileset(local.library_folder, "*.json")
  raw_data       = [for f in local.policy_files : jsondecode(file("${local.library_folder}/${f}"))]
  policies = {
    for f in local.raw_data : f.name => f
  }



}

