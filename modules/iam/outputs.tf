# filepath: d:\CLOUD.DEVOPS RESUMES\project 2 internship\modules\iam\outputs.tf
# Outputs for IAM Tag Enforcement Module

output "policy_arn" {
  description = "ARN of the IAM tag enforcement policy"
  value       = var.enabled ? aws_iam_policy.tag_enforcement[0].arn : ""
}

output "policy_name" {
  description = "Name of the IAM tag enforcement policy"
  value       = var.enabled ? aws_iam_policy.tag_enforcement[0].name : ""
}

output "policy_id" {
  description = "ID of the IAM tag enforcement policy"
  value       = var.enabled ? aws_iam_policy.tag_enforcement[0].id : ""
}

output "exemption_role_arn" {
  description = "ARN of the exemption role (if created)"
  value       = var.enabled && var.create_exemption_role ? aws_iam_role.exemption_role[0].arn : ""
}

output "exemption_role_name" {
  description = "Name of the exemption role (if created)"
  value       = var.enabled && var.create_exemption_role ? aws_iam_role.exemption_role[0].name : ""
}