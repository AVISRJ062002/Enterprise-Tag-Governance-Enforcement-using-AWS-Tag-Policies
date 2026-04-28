# filepath: d:\CLOUD.DEVOPS RESUMES\project 2 internship\modules\tag-policy\variables.tf
# Variables for AWS Tag Policy Module

variable "enabled" {
  description = "Enable or disable the Tag Policy"
  type        = bool
  default     = true
}

variable "policy_name" {
  description = "Name of the Tag Policy"
  type        = string
  default     = "aws-tag-governance-policy"
}

variable "policy_description" {
  description = "Description of the Tag Policy"
  type        = string
  default     = "AWS Tag Policy to enforce required tags and provide compliance visibility"
}

variable "target_ou_id" {
  description = "Organizational Unit ID to attach the Tag Policy (leave empty to skip attachment)"
  type        = string
  default     = ""
}

variable "enforced_resource_types" {
  description = "AWS Organizations tag-policy resource types used for required-tag reporting"
  type        = list(string)
  default = [
    "ec2:instance",
    "ec2:volume",
    "s3:bucket",
    "rds:db",
    "lambda:function",
    "dynamodb:table",
    "elasticache:cachecluster"
  ]

  validation {
    condition = alltrue([
      for resource_type in var.enforced_resource_types :
      can(regex("^[a-z0-9-]+:(ALL_SUPPORTED|[a-z0-9-]+)$", resource_type))
    ])
    error_message = "enforced_resource_types must use AWS Organizations tag-policy syntax such as ec2:instance or ec2:ALL_SUPPORTED."
  }
}

variable "create_recommended_policy" {
  description = "Create a separate policy for recommended (optional) tags"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
