# filepath: d:\CLOUD.DEVOPS RESUMES\project 2 internship\modules\ec2-test\variables.tf
# Variables for EC2 Test Module

variable "enabled" {
  description = "Enable or disable the EC2 test instance"
  type        = bool
  default     = true
}

variable "instance_name" {
  description = "Name of the test EC2 instance"
  type        = string
  default     = "tag-governance-test-instance"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "security_group_name" {
  description = "Name of the security group"
  type        = string
  default     = "tag-governance-test-sg"
}

variable "volume_size" {
  description = "Size of the EBS volume in GiB"
  type        = number
  default     = 10
}

variable "volume_type" {
  description = "Type of the EBS volume (gp2, gp3, io1, etc.)"
  type        = string
  default     = "gp3"
}

# Owner information for required tags
variable "owner_email" {
  description = "Owner email ID (required tag)"
  type        = string
  default     = "owner@example.com"

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
  default     = "Office"
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

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}