# =============================================================================
# AWS Tag Governance Enforcement - Terraform Variables
# =============================================================================
# This file contains the variable values for the Tag Governance project.
# Copy this file to terraform.tfvars and customize as needed.

# =============================================================================
# AWS Configuration
# =============================================================================
aws_region              = "us-east-1"
is_organization_account = false # Set to true if using AWS Organizations

# Default tags applied to all resources
default_tags = {
  Project     = "TagGovernance"
  ManagedBy   = "Terraform"
  Environment = "Production"
  Terraform   = "true"
}

# =============================================================================
# Tag Governance Configuration
# =============================================================================
required_tag_key   = "Name"
required_tag_value = "*"

# Required tags for governance enforcement
required_tag_keys = [
  "Name",
  "emailID",
  "phoneNo",
  "Place"
]

# =============================================================================
# IAM Enforcement Configuration
# =============================================================================
enable_iam_enforcement = true
iam_policy_name        = "aws-tag-governance-deny-policy"
create_exemption_role  = true
exemption_role_pattern = ""
attach_to_role_name    = "" # Set to a role name to attach policy

# =============================================================================
# SCP Enforcement Configuration
# =============================================================================
enable_scp_enforcement = false # Requires AWS Organizations
scp_policy_name        = "require-tag-governance-policy"
enforce_tag_limits     = false
max_tag_count          = 10
target_ou_id           = "" # e.g., "ou-1234-56789012"

# =============================================================================
# Tag Policy Configuration
# =============================================================================
enable_tag_policy              = false # Requires AWS Organizations
tag_policy_name                = "aws-tag-governance-policy"
create_recommended_tags_policy = true

# =============================================================================
# EC2 Test Instance Configuration
# =============================================================================
enable_ec2_test          = true # Set to true to create test instance
enable_launch_demo_role  = true
test_instance_name       = "tag-governance-test-instance"
test_instance_type       = "t3.micro"
test_security_group_name = "tag-governance-test-sg"
test_volume_size         = 10
test_volume_type         = "gp3"

# =============================================================================
# Owner Information (Required Tags)
# =============================================================================
owner_email = "devops@example.com"
owner_phone = "+1-555-0100"
owner_place = "Headquarters"
owner_name  = "DevOps Team"
environment = "dev"
cost_center = "CC-001"
