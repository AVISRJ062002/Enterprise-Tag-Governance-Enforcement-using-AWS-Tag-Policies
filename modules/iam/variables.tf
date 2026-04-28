# filepath: d:\CLOUD.DEVOPS RESUMES\project 2 internship\modules\iam\variables.tf
# Variables for IAM Tag Enforcement Module

variable "enabled" {
  description = "Enable or disable the IAM tag enforcement policy"
  type        = bool
  default     = true
}

variable "policy_name" {
  description = "Name of the IAM policy for tag enforcement"
  type        = string
  default     = "aws-tag-governance-deny-policy"
}

variable "policy_description" {
  description = "Description of the IAM policy"
  type        = string
  default     = "IAM policy to enforce required tags on AWS resources"
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

variable "enforced_ec2_instances" {
  description = "List of ARN patterns for EC2 instances that require tags"
  type        = list(string)
  default     = ["arn:aws:ec2:*:*:instance/*"]
}

variable "exemption_role_pattern" {
  description = "Optional IAM role ARN pattern that is exempt from tag enforcement. Leave empty to auto-match the created exemption role."
  type        = string
  default     = ""
}

variable "exemption_principal_arns" {
  description = "List of principal ARNs that can assume the exemption role. Leave empty to trust the current AWS account root."
  type        = list(string)
  default     = []
}

variable "attach_to_role_name" {
  description = "Role name to attach the tag enforcement policy (optional)"
  type        = string
  default     = ""
}

variable "create_exemption_role" {
  description = "Create an exemption role for break-glass scenarios"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
