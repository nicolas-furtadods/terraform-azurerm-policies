# Azure Policies
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE)

This Terraform feature creates multiples [Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/overview), allowing you to use pre-defined policies, give a list of custom policy files, or use defined policy initiatives like [Azure Security Benchmark](https://docs.microsoft.com/en-us/security/benchmark/azure/overview-v2). Policies deployed will be grouped in initiatives separated by their categories.

## Version compatibility

| Module version | Terraform version | AzureRM version |
|----------------|-------------------|-----------------|
| >= 1.x.x       | 1.1.0             | >= 3.12         |

## Usage

This module is separated between various configuration blocks which depends on your usage.
0. Global Module Configuration
1. Initiative Configuration
2. Custom Policies Configuration
3. Predefined Policies
4. Azure Security Benchmark


### Global Module Configuration
```hcl
module "policies" {
  source = "./terraform-azurerm-policies" # Your path may be different.

  management_group_id = "providers/Microsoft.Management/managementGroups/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  location = "francecentral"
}
```

### Initiative Configuration
```hcl
module "policies" {
  # Previously configured parameters
  # Global Module Parameters are mandatory

  initiatives_parameters = {
    default_policies_non_compliant_message = "Your deployment or action is not compliant with your organization policies." # Optionnal. Default non compliant message
    description = "Initiative set to group policies by category" # Optionnal. Description 
    display_name_prefix = "Azure Policy Governance." # Optionnal. Note that the category key will be appended at the end.
    excluded_scopes = [ ] # Optionnal. Management group, subscriptions, resource groups, resources scopes.
    identity = { # Null for easy assignment
      identity_ids = [ "value" ] # Required when type 'UserAssigned' is set. 
      type = "value" # Optionnal. Add an Identity (MSI) to the function app. Possible values are SystemAssigned or UserAssigned"
    }
  }
}
```

### Custom Policies Configuration
```hcl
module "policies" {
  # Previously configured parameters
  # Global Module Parameters are mandatory

  # Mandatory to use custom policies.
  custom_policy  = {
      library_folder = "./examples" # Mandatory to use custom policies. A folder path containing json files.
  }

  # Optionnal. Key-Value Map. Provide parameters to policies requirying parameters. Key is the policy name. Value should be a JSON string of the policy parameters.
  custom_policy_parameters = {
    "apd-denyclshl" = "<value>"
  }

  # Optionnal. Key-Value Map. Provide non compliance messages to policies requirying it.
  custom_policy_non_compliance_messages = {
    "apd-denyclshl" = "You cannot add your own cloud shell."
  }
}
```

### Azure Security Benchmark
```hcl
module "policies" {
  # Previously configured parameters
  # Global Module Parameters are mandatory

  # Mandatory to use custom policies.
  # Add the object 'enable_azure_security_benchmark' to implement the initiative
  enable_azure_security_benchmark = {
    exemption_reference_list = [ 
      "AzureFirewallEffect"
    ]
  }
}
```
## Arguments Reference

The following arguments are supported:
  - `management_group_id` - (Required) The management group ID. Most resources will be created on its scope.
  - `location` - (Required) Region to deploy the resources.

##
  - `custom_policy` - (Optionnal) A string map of custom policies parameters as defined below.
  - `custom_policy_non_compliance_messages` - (Optionnal) Key-Value Map. Provide non compliance messages to policies requirying it Key is the policy name. Value should be the string message.
  - `custom_policy_parameters` - (Optionnal) Key-Value Map. Provide parameters to policies requirying parameters. Key is the policy name. Value should be a JSON string of the policy parameters.
  - `enable_azure_security_benchmark` - (Optionnal) Provide parameters to the implementation of the initiative 'Azure Security Benchmark' as defined below.
  - `initiatives_parameters` - (Optionnal)  A custom map of initiatives parameters as defined below.

##
A `custom_policy` map support the following:
  - `library_folder` - (Required) A folder path containing json files.

##
A `enable_azure_security_benchmark` object support the following:
  - `exemption_reference_list` - (Optionnal) List of policies' reference ids in the initiatives that will be exempted. A exemption resource will be created.

##
A `initiatives_parameters` object support the following:
  - `default_policies_non_compliant_message` - (Optionnal) Default policy non compliant message.
  - `description` - (Optionnal) Initiative Description.
  - `display_name_prefix` - (Optionnal) Initiative names prefix. Note that the category key will be appended at the end.
  - `excluded_scopes` - (Optionnal) List of Management group, subscriptions, resource groups, resources scopes.
  - `identity` - (Optionnal) . A custom map of identity parameters as defined below
  - `identity_ids` - (Optionnal) . 

##
A `identity` map support the following:
  - `type` - (Required) Possible values are `SystemAssigned` or `UserAssigned` .
  - `identity_ids` - (Optionnal) List of Managed Identity IDs. Required when `type` is set to `UserAssigned`.


## Outputs

| Name | Description |
|------|-------------|

## References
Please check the following references for best practices.
* [Terraform Best Practices](https://www.terraform-best-practices.com/)
* [Azure Policy as Code with Terraform Part 1](https://purple.telstra.com/blog/azure-policy-as-code-with-terraform-part-1)