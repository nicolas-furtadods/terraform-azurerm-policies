# Azure Policies
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE)

This Terraform feature creates multiples [Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/overview), allowing you to use pre-defined policies, give a list of custom policy files, or use defined policy initiatives like [Azure Security Benchmark](https://docs.microsoft.com/en-us/security/benchmark/azure/overview-v2). Policies deployed will be grouped in initiatives separated by their categories.

## Version compatibility

| Module version | Terraform version | AzureRM version |
|----------------|-------------------|-----------------|
| >= 1.x.x       | 1.1.0             | >= 3.12         |

## Usage

Except Global Module Configuration, This module is separated between various configuration blocks which depends on your usage.
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
    identity = { 
      identity_ids = [ "value" ] # Required when type 'UserAssigned' is set. 
      type = "value" # Optionnal. Add an Identity (MSI) to the function app. Possible values are SystemAssigned or UserAssigned"
    }
    category_exclusive_parameters = {
      "Guest Configuration" : {
        enforce         = false
        excluded_scopes = [ "value" ]
      } 
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
    library_folder = "./Policy Libraries"
    policy_exclusive_parameters = {
      "apd-denyclsh" : {
        parameter_values       = null
        non_compliance_message = "The creation of user-specific Cloud shell is denied. Please contact Azure CloudOps to get a centralized file share access"
      }
    }
  }
}
```
| ⚠ The key must be the policy name, as the module uses lookup to search for attribute |
|--------------------------------------------------------------------------------------|


### Predefined Policies
```hcl
module "policies" {
  # Previously configured parameters
  # Global Module Parameters are mandatory

  # Refer to arguments reference
  predefined_policies = {
    "e56962a6-4747-49cd-b67b-bf8b01975c4c" = {
      display_name           = "Allowed locations",
      name                   = "e56962a6-4747-49cd-b67b-bf8b01975c4c",
      category               = "General",
      parameters             = "{\"listOfAllowedLocations\":{\"value\":[\"francecentral\",\"westeurope\"]}}",
      non_compliance_message = "Your deployment have been denied by Azure Policy. You must deploy in a region authorized by Azure Admins/CloudOps.",
    }
  }
}
```


### Predefined Initiatives
```hcl
module "policies" {
  # Previously configured parameters
  # Global Module Parameters are mandatory

  predefined_initiatives = {
    "securityben" : {
      initiative_name          = "Azure Security Benchmark"
      exemption_reference_list = [ "AzureFirewallEffect" ]
    }
    "dplgc" : {
      initiative_name          = "Deploy prerequisites to enable Guest Configuration policies on virtual machines"
      exemption_reference_list = null
    }
  }
}
```

## Arguments Reference

The following arguments are supported:
  - `management_group_id` - (Required) The management group ID. Most resources will be created on its scope.
  - `location` - (Required) Region to deploy the resources.

##
  - `custom_policy` - (Optionnal) A `custom_policy` Object as defined below.
  - `initiatives_parameters` - (Optionnal)  A `initiatives_parameters` map as defined below.
  - `predefined_initiatives` - (Optionnal)  A map of `predefined_initiatives` object as defined below.
  - `predefined_policies` - (Optionnal)  A map of `predefined_policies` object as defined below.

##
A `category_exclusive_parameters` object support the following:
  - `initiative_name` - (Required) Name of the initiative to assign.
  - `excluded_scopes` - (Optionnal) List of Management group, subscriptions, resource groups, resources scopes for the specific category. Will be merge with the initiatives global excluded scopes.

##
A `custom_policy` map support the following:
  - `library_folder` - (Required) A folder path containing json files.
  - `policy_excluive_parameters` - (Optionnal) A map of `policy_excluive_parameters` object as defined below.


##
A `identity` object support the following:
  - `type` - (Required) Possible values are `SystemAssigned` or `UserAssigned` .
  - `identity_ids` - (Optionnal) List of Managed Identity IDs. Required when `type` is set to `UserAssigned`.

##
A `initiatives_parameters` object support the following:
  - `default_policies_non_compliant_message` - (Optionnal) Default policy non compliant message.
  - `description` - (Optionnal) Initiative Description.
  - `display_name_prefix` - (Optionnal) Initiative names prefix. Note that the category key will be appended at the end.
  - `excluded_scopes` - (Optionnal) List of Management group, subscriptions, resource groups, resources scopes.
  - `identity` - (Optionnal) . A custom object as defined above
  - `category_exclusive_parameters` - (Optionnal) . A custom map of `category_exclusive_parameters` objects as defined above


##
A `policy_excluive_parameters` object support the following:
  - `parameter_values` - (Optionnal) Policy Parameters as JSON string.
  - `non_compliance_message` - (Optionnal) Policy specific non compliance message.

| ⚠ The key must be the policy name, as the module uses lookup to search for attribute |
|--------------------------------------------------------------------------------------|

##
A `predefined_initiatives` object support the following:
  - `initiative_name` - (Required) The name of the initiative to implement
  - `exemption_reference_list` - (Optionnal) List of policies reference ids in the initiative that you want exempted.

##
A `predefined_policies` object support the following:
  - `display_name` - (Required) The display name of the Policy.
  - `name` - (Required) The ID/Name of the policy definition.
  - `category` - (Required) The Policy Definition Category.
  - `parameters` - (Optionnal) String JSON value of the policy parameters.
  - `non_compliance_message` - (Optionnal) A specific non compliance message for the policy


## Outputs

| Name | Description |
|------|-------------|

## References
Please check the following references for best practices.
* [Terraform Best Practices](https://www.terraform-best-practices.com/)
* [Azure Policy as Code with Terraform Part 1](https://purple.telstra.com/blog/azure-policy-as-code-with-terraform-part-1)