# filepath: d:\CLOUD.DEVOPS RESUMES\project 2 internship\modules\scp\main.tf
# SCP (Service Control Policy) Module for Tag Governance
# This module creates SCPs to enforce tag compliance at the organization level

locals {
  create_actions = [
    "ec2:RunInstances",
    "ec2:CreateVolume",
    "s3:CreateBucket",
    "s3:PutObject",
    "rds:CreateDBInstance",
    "lambda:CreateFunction",
    "dynamodb:CreateTable",
    "elasticache:CreateCacheCluster"
  ]

  tag_mutation_actions = [
    "ec2:DeleteTags",
    "s3:DeleteObjectTagging"
  ]

  lifecycle_actions = [
    "ec2:TerminateInstances",
    "ec2:DeleteVolume",
    "s3:DeleteBucket",
    "rds:DeleteDBInstance",
    "lambda:DeleteFunction"
  ]

  exemption_condition = length(var.exempted_role_patterns) > 0 ? {
    ArnNotLike = {
      "aws:PrincipalARN" = var.exempted_role_patterns
    }
  } : {}

  create_required_tag_statements = [
    for idx, tag_key in var.required_tag_keys : {
      Sid      = "DenyCreateWithoutRequiredTag${idx}"
      Effect   = "Deny"
      Action   = local.create_actions
      Resource = var.enforced_resource_types
      Condition = merge(local.exemption_condition, {
        Null = {
          "aws:RequestTag/${tag_key}" = "true"
        }
      })
    }
  ]

  primary_tag_value_statements = var.required_tag_value == "*" ? [] : [
    {
      Sid      = "DenyCreateWithInvalidPrimaryTagValue"
      Effect   = "Deny"
      Action   = local.create_actions
      Resource = var.enforced_resource_types
      Condition = merge(local.exemption_condition, {
        Null = {
          "aws:RequestTag/${var.required_tag_key}" = "false"
        }
        StringNotEquals = {
          "aws:RequestTag/${var.required_tag_key}" = var.required_tag_value
        }
      })
    }
  ]

  protected_tag_statements = [
    {
      Sid      = "DenyDeleteRequiredTags"
      Effect   = "Deny"
      Action   = local.tag_mutation_actions
      Resource = "*"
      Condition = merge(local.exemption_condition, {
        "ForAnyValue:StringEquals" = {
          "aws:TagKeys" = var.required_tag_keys
        }
      })
    }
  ]

  lifecycle_required_tag_statements = [
    for idx, tag_key in var.required_tag_keys : {
      Sid      = "DenyLifecycleWithoutRequiredTag${idx}"
      Effect   = "Deny"
      Action   = local.lifecycle_actions
      Resource = var.enforced_ec2_resources
      Condition = merge(local.exemption_condition, {
        Null = {
          "aws:ResourceTag/${tag_key}" = "true"
        }
      })
    }
  ]
}

# Get organization information
data "aws_organizations_organization" "this" {
  count = var.enabled ? 1 : 0
}

data "aws_organizations_organizational_units" "this" {
  count     = var.enabled ? 1 : 0
  parent_id = data.aws_organizations_organization.this[0].roots[0].id
}

# SCP to require tags on all resources
resource "aws_organizations_policy" "require_tags" {
  count       = var.enabled ? 1 : 0
  name        = var.policy_name
  description = var.policy_description
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      local.create_required_tag_statements,
      local.primary_tag_value_statements,
      local.protected_tag_statements,
      local.lifecycle_required_tag_statements
    )
  })

  tags = var.tags
}

# SCP to enforce tag limits (prevent excessive tags)
resource "aws_organizations_policy" "limit_tags" {
  count       = var.enabled && var.enforce_tag_limits ? 1 : 0
  name        = "${var.policy_name}-limit"
  description = "SCP to limit the number of tags allowed on resources"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "DenyExcessiveTags"
        Effect = "Deny"
        Action = [
          "ec2:CreateTags",
          "s3:PutObjectTagging"
        ]
        Resource = "*"
        Condition = {
          "NumericGreaterThan" : {
            "aws:RequestTagKeys" : var.max_tag_count
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Attach SCP to organizational units
resource "aws_organizations_policy_attachment" "require_tags_attachment" {
  count     = var.enabled && var.target_ou_id != "" ? 1 : 0
  policy_id = aws_organizations_policy.require_tags[0].id
  target_id = var.target_ou_id
}

resource "aws_organizations_policy_attachment" "limit_tags_attachment" {
  count     = var.enabled && var.enforce_tag_limits && var.target_ou_id != "" ? 1 : 0
  policy_id = aws_organizations_policy.limit_tags[0].id
  target_id = var.target_ou_id
}
