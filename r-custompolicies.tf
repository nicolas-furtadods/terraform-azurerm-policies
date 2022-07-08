##########################################################################
# 2. Custom Policies
##########################################################################

module "custom_policy" {
  for_each = local.policies
  source   = "./Policy Definition"

  name                = each.key
  mode                = each.value.properties.mode
  display_name        = each.value.properties.displayName
  description         = each.value.properties.description
  management_group_id = var.management_group_id
  metadata            = jsonencode("${each.value.properties.metadata}") #format("<<METADATA \n %s \n METADATA", each.value.properties.metadata)
  parameters          = lookup(each.value.properties, "parameters", null) != null ? jsonencode(lookup(each.value.properties, "parameters")) : null
  rule                = jsonencode("${each.value.properties.policyRule}") #format("<<POLICYRULE \n %s \n POLICYRULE", each.value.properties.policyRule)
}