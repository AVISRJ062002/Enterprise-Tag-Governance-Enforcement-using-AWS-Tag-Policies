# filepath: d:\CLOUD.DEVOPS RESUMES\project 2 internship\modules\scp\variables.tf
# Variables for SCP Tag Governance Module

variable "enabled" {
  description = "Enable or disable the SCP tag enforcement"
  type        = bool
  default     = true
}

variable "policy_name" {
  description = "Name of the SCP for tag enforcement"
  type        = string
  default     = "require-tag-governance-policy"
}

variable "policy_description" {
  description = "Description of the SCP"
  type        = string
  default     = "Service Control Policy to enforce required tags on all resources"
}

variable "required_tag_key" {
  description = "The required tag key that must be present on resources"
  type        = string
  default     = "Name"
}

variable "required_tag_value" {
  description = "The required tag value pattern (use * for any value)"
  type        = string
  default     = "*"
}

variable "required_tag_keys" {
  description = "List of required tag keys that must be present"
  type        = list(string)
  default     = ["Name", "emailID", "phoneNo", "Place"]
}

variable "enforce_tag_limits" {
  description = "Reserved for future use. AWS Organizations SCPs do not expose a reliable tag-count condition key."
  type        = bool
  default     = false

  validation {
    condition     = var.enforce_tag_limits == false
    error_message = "enforce_tag_limits is not supported because AWS Organizations SCPs cannot reliably enforce a numeric tag-count limit."
  }
}

variable "max_tag_count" {
  description = "Maximum number of tags allowed per resource"
  type        = number
  default     = 10
}

variable "target_ou_id" {
  description = "Organizational Unit ID to attach the SCP (leave empty to skip attachment)"
  type        = string
  default     = ""
}

variable "exempted_resource_arns" {
  description = "List of resource ARNs exempted from tag enforcement"
  type        = list(string)
  default     = []
}

variable "exempted_role_patterns" {
  description = "List of role ARN patterns exempted from tag enforcement"
  type        = list(string)
  default     = ["arn:aws:iam::*:role/TagEnforcementExemption"]
}

variable "enforced_ec2_resources" {
  description = "List of EC2 resource ARNs to enforce termination protection"
  type        = list(string)
  default     = ["arn:aws:ec2:*:*:instance/*"]
}

variable "enforced_resource_types" {
  description = "List of ARN patterns for resources that require tags"
  type        = list(string)
  default = [
    "arn:aws:ec2:*:*:instance/*",
    "arn:aws:ec2:*:*:volume/*",
    "arn:aws:s3:::*",
    "arn:aws:rds:*:*:db:*",
    "arn:aws:lambda:*:*:function:*",
    "arn:aws:dynamodb:*:*:table/*",
    "arn:aws:elasticache:*:*:cachecluster/*"
  ]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
