# filepath: d:\CLOUD.DEVOPS RESUMES\project 2 internship\outputs.tf
# Root Configuration Outputs for AWS Tag Governance

# =============================================================================
# Account Information
# =============================================================================
output "account_id" {
  description = "Current AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS Region"
  value       = var.aws_region
}

output "organization_id" {
  description = "AWS Organization ID (if in organization)"
  value       = var.is_organization_account ? data.aws_organizations_organization.org[0].id : ""
}

# =============================================================================
# IAM Module Outputs
# =============================================================================
output "iam_policy_arn" {
  description = "ARN of the IAM tag enforcement policy"
  value       = module.iam_tag_enforcement.policy_arn
}

output "iam_policy_name" {
  description = "Name of the IAM tag enforcement policy"
  value       = module.iam_tag_enforcement.policy_name
}

output "iam_exemption_role_arn" {
  description = "ARN of the exemption role"
  value       = module.iam_tag_enforcement.exemption_role_arn
}

output "iam_exemption_role_name" {
  description = "Name of the exemption role"
  value       = module.iam_tag_enforcement.exemption_role_name
}

# =============================================================================
# SCP Module Outputs
# =============================================================================
output "scp_policy_id" {
  description = "ID of the SCP for tag enforcement"
  value       = module.scp_tag_enforcement.require_tags_policy_id
}

output "scp_policy_arn" {
  description = "ARN of the SCP for tag enforcement"
  value       = module.scp_tag_enforcement.require_tags_policy_arn
}

# =============================================================================
# Tag Policy Module Outputs
# =============================================================================
output "tag_policy_id" {
  description = "ID of the AWS Tag Policy"
  value       = module.tag_policy.tag_policy_id
}

output "tag_policy_arn" {
  description = "ARN of the AWS Tag Policy"
  value       = module.tag_policy.tag_policy_arn
}

output "recommended_tags_policy_id" {
  description = "ID of the recommended tags policy"
  value       = module.tag_policy.recommended_tags_policy_id
}

# =============================================================================
# EC2 Test Module Outputs
# =============================================================================
output "test_instance_id" {
  description = "ID of the test EC2 instance"
  value       = module.ec2_test.instance_id
}

output "test_instance_public_ip" {
  description = "Public IP of the test EC2 instance"
  value       = module.ec2_test.instance_public_ip
}

output "test_instance_private_ip" {
  description = "Private IP of the test EC2 instance"
  value       = module.ec2_test.instance_private_ip
}

output "test_security_group_id" {
  description = "ID of the test security group"
  value       = module.ec2_test.security_group_id
}

output "test_volume_id" {
  description = "ID of the test EBS volume"
  value       = module.ec2_test.volume_id
}

output "test_instance_tags" {
  description = "Tags applied to the test instance"
  value       = module.ec2_test.instance_tags
}

output "launch_demo_role_arn" {
  description = "ARN of the IAM role used for real launch success/failure demonstrations"
  value       = var.enable_launch_demo_role ? aws_iam_role.launch_demo[0].arn : ""
}

output "launch_demo_role_name" {
  description = "Name of the IAM role used for real launch success/failure demonstrations"
  value       = var.enable_launch_demo_role ? aws_iam_role.launch_demo[0].name : ""
}

# =============================================================================
# Compliance Summary
# =============================================================================
output "compliance_summary" {
  description = "Summary of enabled compliance enforcements"
  value = {
    iam_enforcement_enabled = var.enable_iam_enforcement
    scp_enforcement_enabled = var.enable_scp_enforcement
    tag_policy_enabled      = var.enable_tag_policy
    ec2_test_enabled        = var.enable_ec2_test
    required_tags           = var.required_tag_keys
    exemption_role_created  = var.create_exemption_role
  }
}
