variable "name" {
  type        = string
  description = "Policy Name of the custom policy"
}

variable "mode" {
  type        = string
  description = "Policy Mode"
  default     = "Indexed"
}

variable "display_name" {
  type        = string
  description = "Policy Display Name of the custom policy"
}

variable "description" {
  type        = string
  description = "Policy Description"
}

variable "management_group_id" {
  type        = string
  description = "Management group ID"
}

variable "metadata" {
  type        = string
  description = "Policy Metadata as String. Use jsonencode() if needed."
}

variable "parameters" {
  type        = string
  description = "Policy Parameters as String. Use jsonencode() if needed."
}

variable "rule" {
  type        = string
  description = "Policy Rules as String. Use jsonencode() if needed."
}









