# filepath: d:\CLOUD.DEVOPS RESUMES\project 2 internship\modules\scp\outputs.tf
# Outputs for SCP Tag Governance Module

output "organization_id" {
  description = "AWS Organization ID"
  value       = var.enabled ? data.aws_organizations_organization.this[0].id : ""
}

output "require_tags_policy_id" {
  description = "ID of the require tags SCP"
  value       = var.enabled ? aws_organizations_policy.require_tags[0].id : ""
}

output "require_tags_policy_arn" {
  description = "ARN of the require tags SCP"
  value       = var.enabled ? aws_organizations_policy.require_tags[0].arn : ""
}

output "limit_tags_policy_id" {
  description = "ID of the tag limits SCP (if enabled)"
  value       = var.enabled && var.enforce_tag_limits ? aws_organizations_policy.limit_tags[0].id : ""
}

output "roots" {
  description = "List of organization roots"
  value       = var.enabled ? data.aws_organizations_organization.this[0].roots : []
}

output "organizational_units" {
  description = "List of organizational units"
  value       = var.enabled ? data.aws_organizations_organizational_units.this[0].children : []
}