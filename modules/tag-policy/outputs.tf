# filepath: d:\CLOUD.DEVOPS RESUMES\project 2 internship\modules\tag-policy\outputs.tf
# Outputs for AWS Tag Policy Module

output "tag_policy_id" {
  description = "ID of the Tag Policy"
  value       = var.enabled ? aws_organizations_policy.tag_policy[0].id : ""
}

output "tag_policy_arn" {
  description = "ARN of the Tag Policy"
  value       = var.enabled ? aws_organizations_policy.tag_policy[0].arn : ""
}

output "recommended_tags_policy_id" {
  description = "ID of the recommended tags policy (if created)"
  value       = var.enabled && var.create_recommended_policy ? aws_organizations_policy.recommended_tags[0].id : ""
}

output "recommended_tags_policy_arn" {
  description = "ARN of the recommended tags policy (if created)"
  value       = var.enabled && var.create_recommended_policy ? aws_organizations_policy.recommended_tags[0].arn : ""
}

output "organization_id" {
  description = "AWS Organization ID"
  value       = var.enabled ? data.aws_organizations_organization.this[0].id : ""
}