# DEPRECATED - Azure Function App
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE)

| ⚠ This module is deprecated, please use [function-app](https://registry.terraform.io/modules/claranet/function-app/azurerm/) module |
|-------------------------------------------------------------------------------------------------------------------------------------|

This Terraform feature creates multiples [Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/overview), allowing you to use pre-defined policies, give a list of custom policy files, or use defined policy initiatives like [Azure Security Benchmark](https://docs.microsoft.com/en-us/security/benchmark/azure/overview-v2). Policies deployed will be grouped in initiatives separated by their categories.

## Version compatibility

| Module version | Terraform version | AzureRM version |
|----------------|-------------------|-----------------|
| >= 1.x.x       | 1.1.0             | >= 3.12         |

## Usage

This module is separated between various configuration blocks which depends on your usage.
1. Global Module Configuration
2. Initiative Configuration
3. Custom Policies Configuration


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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| custom\_policy.library\_folder  | Mandatory to use custom policies feature. A folder path containing json files | `string` | n/a | no |
| custom\_policy\_non\_compliance\_messages  | Key-Value Map. Provide non compliance messages to policies requirying it. | `map(string)` | n/a | no |
| custom\_policy\_parameters  | Key-Value Map. Provide parameters to policies requirying parameters. Key is the policy name. Value should be a JSON string of the policy parameters. | `map(string)` | n/a | no |
| initiatives\_parameters.default\_policies\_non\_compliant\_message | Default non compliant message | `string` | `Your deployment or action is not compliant with your organization policies [...]`| no |
| initiatives\_parameters.description | Initiative Description | `string` | `Initiative set to group policies by category`| no |
| initiatives\_parameters.display\_name\_prefix | Initiative names prefix. | `string` | `Azure Policy Governance -`| no |
| initiatives\_parameters.excluded\_scopes  | Optionnal. Management group, subscriptions, resource groups, resources scopes. | `string` | n/a| no |
| initiatives\_parameters.identity.identity_ids | List of Managed Identity IDs. | `list(string)` | n/a | no |
| initiatives\_parameters.identity.type | Possible values are SystemAssigned or UserAssigned" | `string` | n/a | no |
| location | The management group ID. Region to deploy the resources | `string` | n/a | yes |
| management\_group\_id | The management group ID. Most resources will be created on its scope | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|

## References
Please check the following references for best practices.
* [Terraform Best Practices](https://www.terraform-best-practices.com/)
* [Azure Policy as Code with Terraform Part 1](https://purple.telstra.com/blog/azure-policy-as-code-with-terraform-part-1)