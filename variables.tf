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

  })
  description = "Parameters for naming initiatives."

  default = {
    description                            = "Initiative set to group policies by category"
    display_name_prefix                    = "Azure Policy Governance -"
    default_policies_non_compliant_message = "Your deployment or action is not compliant with your organization policies. Please check the error for more details and/or contact your Azure admin."
    excluded_scopes                        = []
    identity                               = null
  }
}

##########################################################################
# 2. Custom Policies
##########################################################################

variable "custom_policy" {
  type        = map(string)
  description = "Map attributes for custom policies. \n library_folder: A library folder path which contains JSON policies to be loaded and added."
  default     = {}
}

variable "custom_policy_parameters" {
  type        = map(string)
  description = "Map list of policy name and their parameters as values."
  default     = {}
}

variable "custom_policy_non_compliance_messages" {
  type        = map(string)
  description = "Map list of policy name and their parameters as values."
  default     = {}
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
}

##########################################################################
# 4. Security Benchmark
##########################################################################

variable "enable_azure_security_benchmark" {
  type = object({
    exemption_reference_list = list(string)
  })
  description = "Enable the predefined 'Azure security Benchmark initiative'."
  default     = null
}

##########################################################################
# 5. Guest Policies
##########################################################################
variable "predefined_guest_policies" {
  type = map(object({
    display_name           = string
    name                   = string
    category               = string
    parameters             = string
    non_compliance_message = string
  }))
  description = "A list of policies to apply on the defined management group. This list will be enforced."
}
