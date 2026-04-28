# filepath: d:\CLOUD.DEVOPS RESUMES\project 2 internship\variables.tf
# Root Configuration Variables for AWS Tag Governance

# =============================================================================
# AWS Configuration
# =============================================================================
variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "aws_region must be a valid AWS region (e.g., us-east-1, us-west-2)."
  }
}

variable "is_organization_account" {
  description = "Is this account an AWS Organizations management or delegated admin account?"
  type        = bool
  default     = false
}

variable "default_tags" {
  description = "Default tags applied to all resources"
  type        = map(string)
  default = {
    Project     = "TagGovernance"
    ManagedBy   = "Terraform"
    Environment = "Production"
  }
}

variable "module_tags" {
  description = "Tags applied to module resources"
  type        = map(string)
  default     = {}
}

# =============================================================================
# Tag Governance Configuration
# =============================================================================
variable "required_tag_key" {
  description = "The primary required tag key"
  type        = string
  default     = "Name"
}

variable "required_tag_value" {
  description = "Exact value required for required_tag_key. Use * to allow any value."
  type        = string
  default     = "*"
}

variable "required_tag_keys" {
  description = "List of all required tag keys for governance"
  type        = list(string)
  default     = ["Name", "emailID", "phoneNo", "Place"]

  validation {
    condition     = length(var.required_tag_keys) >= 4
    error_message = "At least 4 required tag keys must be defined (Name, emailID, phoneNo, Place)."
  }

  validation {
    condition     = contains(var.required_tag_keys, var.required_tag_key)
    error_message = "required_tag_keys must include required_tag_key."
  }
}

variable "enforced_resource_types" {
  description = "List of resource types to enforce tag compliance"
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

variable "tag_policy_resource_types" {
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
      for resource_type in var.tag_policy_resource_types :
      can(regex("^[a-z0-9-]+:(ALL_SUPPORTED|[a-z0-9-]+)$", resource_type))
    ])
    error_message = "tag_policy_resource_types must use AWS Organizations tag-policy syntax such as ec2:instance or ec2:ALL_SUPPORTED."
  }
}

# =============================================================================
# IAM Enforcement Configuration
# =============================================================================
variable "enable_iam_enforcement" {
  description = "Enable IAM-based tag enforcement"
  type        = bool
  default     = true
}

variable "iam_policy_name" {
  description = "Name of the IAM tag enforcement policy"
  type        = string
  default     = "aws-tag-governance-deny-policy"
}

variable "exemption_role_pattern" {
  description = "Optional IAM role ARN pattern that is exempt from tag enforcement. Leave empty to auto-match the Terraform-created exemption role."
  type        = string
  default     = ""
}

variable "exempted_role_patterns" {
  description = "List of role ARN patterns exempted from tag enforcement"
  type        = list(string)
  default     = ["arn:aws:iam::*:role/TagEnforcementExemption"]
}

variable "create_exemption_role" {
  description = "Create an exemption role for break-glass scenarios"
  type        = bool
  default     = true
}

variable "attach_to_role_name" {
  description = "Role name to attach the tag enforcement policy (optional)"
  type        = string
  default     = ""
}

# =============================================================================
# SCP Enforcement Configuration
# =============================================================================
variable "enable_scp_enforcement" {
  description = "Enable SCP-based tag enforcement (requires AWS Organizations)"
  type        = bool
  default     = false
}

variable "scp_policy_name" {
  description = "Name of the SCP for tag enforcement"
  type        = string
  default     = "require-tag-governance-policy"
}

variable "enforce_tag_limits" {
  description = "Whether to enforce tag count limits via SCP"
  type        = bool
  default     = false
}

variable "max_tag_count" {
  description = "Maximum number of tags allowed per resource"
  type        = number
  default     = 10
}

variable "target_ou_id" {
  description = "Organizational Unit ID to attach SCP/Tag Policy (leave empty to skip)"
  type        = string
  default     = ""
}

# =============================================================================
# Tag Policy Configuration
# =============================================================================
variable "enable_tag_policy" {
  description = "Enable AWS Tag Policy for compliance visibility"
  type        = bool
  default     = false
}

variable "tag_policy_name" {
  description = "Name of the AWS Tag Policy"
  type        = string
  default     = "aws-tag-governance-policy"
}

variable "create_recommended_tags_policy" {
  description = "Create a separate policy for recommended (optional) tags"
  type        = bool
  default     = true
}

# =============================================================================
# EC2 Test Instance Configuration
# =============================================================================
variable "enable_ec2_test" {
  description = "Enable EC2 test instance for validation"
  type        = bool
  default     = false
}

variable "enable_launch_demo_role" {
  description = "Create a dedicated IAM role for real launch success/failure demonstrations"
  type        = bool
  default     = false
}

variable "launch_demo_role_name" {
  description = "Name of the IAM role used for launch success/failure demonstrations"
  type        = string
  default     = "tag-governance-demo-launch-role"
}

variable "test_instance_name" {
  description = "Name of the test EC2 instance"
  type        = string
  default     = "tag-governance-test-instance"
}

variable "test_instance_type" {
  description = "EC2 instance type for test instance"
  type        = string
  default     = "t3.micro"
}

variable "test_security_group_name" {
  description = "Name of the security group for test instance"
  type        = string
  default     = "tag-governance-test-sg"
}

variable "test_volume_size" {
  description = "Size of the EBS volume in GiB"
  type        = number
  default     = 10
}

variable "test_volume_type" {
  description = "Type of the EBS volume (gp2, gp3, io1, etc.)"
  type        = string
  default     = "gp3"
}

# =============================================================================
# Owner Information (Required Tags)
# =============================================================================
variable "owner_email" {
  description = "Owner email ID (required tag)"
  type        = string
  default     = "devops@example.com"

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.owner_email))
    error_message = "owner_email must be a valid email address."
  }
}

variable "owner_phone" {
  description = "Owner phone number (required tag)"
  type        = string
  default     = "+1-555-0100"

  validation {
    condition     = length(var.owner_phone) >= 10
    error_message = "owner_phone must be at least 10 characters."
  }
}

variable "owner_place" {
  description = "Owner location/place (required tag)"
  type        = string
  default     = "Headquarters"
}

variable "owner_name" {
  description = "Owner name (optional tag)"
  type        = string
  default     = "DevOps Team"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "environment must be one of: dev, staging, prod, test."
  }
}

variable "cost_center" {
  description = "Cost center for FinOps tracking"
  type        = string
  default     = "CC-001"
}
