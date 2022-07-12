##########################################################################
# 0. Core
##########################################################################

variable "management_group_id" {
  description = "Please enter the management group ID. Most resources will be created on its scope"
}

variable "location" {
  type        = string
  description = "Region to deploy the resources"
}

##########################################################################
# 1. Initiatives definition and Assignments
##########################################################################

variable "initiatives_parameters" {
  type = object({
    display_name_prefix                    = string       #Initiative names prefix.
    description                            = string       #Initiative descriptions
    excluded_scopes                        = list(string) #Excluded list of scopes under a management group scope. These scopes will be ignored by policies.
    default_policies_non_compliant_message = string       # Default Policy Non compliant message
    identity = object({
      type         = string
      identity_ids = list(string)
    })
    category_exclusive_parameters = map(object({
      enforce         = bool,
      excluded_scopes = list(string)
    }))

  })
  description = "Parameters for naming initiatives."

  default = {
    description                            = "Initiative set to group policies by category"
    display_name_prefix                    = "Azure Policy Governance -"
    default_policies_non_compliant_message = "Your deployment or action is not compliant with your organization policies. Please check the error for more details and/or contact your Azure admin."
    excluded_scopes                        = []
    identity                               = null
    category_exclusive_parameters          = null
  }
}

##########################################################################
# 2. Custom Policies
##########################################################################

variable "custom_policy" {
  type = object({
    library_folder = string
    policy_exclusive_parameters = map(object({
      parameter_values       = string
      non_compliance_message = string
    }))
  })
  description = "Map attributes for custom policies. \n library_folder: A library folder path which contains JSON policies to be loaded and added."
  default = {
    library_folder              = "."
    policy_exclusive_parameters = {}
  }
}

##########################################################################
# 3. Enforce existing policies
##########################################################################
variable "predefined_policies" {
  type = map(object({
    display_name           = string
    name                   = string
    category               = string
    parameters             = string
    non_compliance_message = string
  }))
  description = "A list of policies to apply on the defined management group. This list will be enforced."
  default     = {}
}

##########################################################################
# 4. Predefined Initiatives Deployments
##########################################################################

variable "predefined_initiatives" {
  type = map(object({
    initiative_name          = string
    exemption_reference_list = list(string)
  }))
  description = "Deploy initiatives based on the information sent."
  default     = {}
}


