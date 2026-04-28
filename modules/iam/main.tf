# filepath: d:\CLOUD.DEVOPS RESUMES\project 2 internship\modules\iam\main.tf
# IAM Module for Tag Governance Enforcement
# This module creates IAM policies to enforce tag compliance

locals {
  create_actions = [
    "ec2:RunInstances",
    "ec2:CreateVolume",
    "s3:PutObject",
    "s3:CreateBucket",
    "rds:CreateDBInstance",
    "lambda:CreateFunction",
    "dynamodb:CreateTable",
    "elasticache:CreateCacheCluster"
  ]

  tag_mutation_actions = [
    "ec2:DeleteTags",
    "s3:DeleteObjectTagging"
  ]

  instance_lifecycle_actions = [
    "ec2:StopInstances",
    "ec2:TerminateInstances"
  ]

  required_tag_map = {
    for idx, tag_key in var.required_tag_keys : idx => tag_key
  }

  effective_exemption_role_pattern = var.exemption_role_pattern != "" ? var.exemption_role_pattern : "arn:aws:iam::*:role/${var.policy_name}-exemption-role"
  effective_exemption_principal_arns = length(var.exemption_principal_arns) > 0 ? var.exemption_principal_arns : [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "tag_enforcement" {
  count = var.enabled ? 1 : 0

  dynamic "statement" {
    for_each = local.required_tag_map

    content {
      sid       = "DenyCreateWithoutRequiredTag${statement.key}"
      effect    = "Deny"
      resources = var.enforced_resource_types
      actions   = local.create_actions

      condition {
        test     = "Null"
        variable = "aws:RequestTag/${statement.value}"
        values   = ["true"]
      }

      condition {
        test     = "ArnNotLike"
        variable = "aws:PrincipalARN"
        values   = [local.effective_exemption_role_pattern]
      }
    }
  }

  dynamic "statement" {
    for_each = var.required_tag_value == "*" ? [] : [var.required_tag_key]

    content {
      sid       = "DenyCreateWithInvalidPrimaryTagValue"
      effect    = "Deny"
      resources = var.enforced_resource_types
      actions   = local.create_actions

      condition {
        test     = "Null"
        variable = "aws:RequestTag/${statement.value}"
        values   = ["false"]
      }

      condition {
        test     = "StringNotEquals"
        variable = "aws:RequestTag/${statement.value}"
        values   = [var.required_tag_value]
      }

      condition {
        test     = "ArnNotLike"
        variable = "aws:PrincipalARN"
        values   = [local.effective_exemption_role_pattern]
      }
    }
  }

  statement {
    sid       = "DenyDeleteRequiredTags"
    effect    = "Deny"
    resources = ["*"]
    actions   = local.tag_mutation_actions

    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "aws:TagKeys"
      values   = var.required_tag_keys
    }

    condition {
      test     = "ArnNotLike"
      variable = "aws:PrincipalARN"
      values   = [local.effective_exemption_role_pattern]
    }
  }

  dynamic "statement" {
    for_each = local.required_tag_map

    content {
      sid       = "DenyLifecycleWithoutRequiredTag${statement.key}"
      effect    = "Deny"
      resources = var.enforced_ec2_instances
      actions   = local.instance_lifecycle_actions

      condition {
        test     = "Null"
        variable = "aws:ResourceTag/${statement.value}"
        values   = ["true"]
      }

      condition {
        test     = "ArnNotLike"
        variable = "aws:PrincipalARN"
        values   = [local.effective_exemption_role_pattern]
      }
    }
  }
}

# Create the IAM policy
resource "aws_iam_policy" "tag_enforcement" {
  count       = var.enabled ? 1 : 0
  name        = var.policy_name
  description = var.policy_description
  policy      = data.aws_iam_policy_document.tag_enforcement[0].json

  tags = var.tags
}

# Attach policy to roles (optional - for testing)
resource "aws_iam_role_policy_attachment" "tag_enforcement" {
  count      = var.enabled && var.attach_to_role_name != "" ? 1 : 0
  role       = var.attach_to_role_name
  policy_arn = aws_iam_policy.tag_enforcement[0].arn
}

# Create exemption role (for break-glass scenarios)
resource "aws_iam_role" "exemption_role" {
  count              = var.enabled && var.create_exemption_role ? 1 : 0
  name               = "${var.policy_name}-exemption-role"
  assume_role_policy = data.aws_iam_policy_document.exemption_assume_role[0].json

  tags = var.tags
}

data "aws_iam_policy_document" "exemption_assume_role" {
  count = var.enabled && var.create_exemption_role ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.effective_exemption_principal_arns
    }

    actions = ["sts:AssumeRole"]
  }
}

# Inline policy for exemption role (allows all actions with tags)
resource "aws_iam_policy" "exemption_role_policy" {
  count       = var.enabled && var.create_exemption_role ? 1 : 0
  name        = "${var.policy_name}-exemption-policy"
  description = "Allows bypass of tag enforcement for break-glass scenarios"
  policy      = data.aws_iam_policy_document.exemption_role_permissions[0].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "exemption_role_attachment" {
  count      = var.enabled && var.create_exemption_role ? 1 : 0
  role       = aws_iam_role.exemption_role[0].name
  policy_arn = aws_iam_policy.exemption_role_policy[0].arn
}

data "aws_iam_policy_document" "exemption_role_permissions" {
  count = var.enabled && var.create_exemption_role ? 1 : 0

  statement {
    sid       = "AllowAllTagOperations"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:*",
      "s3:*",
      "rds:*",
      "lambda:*",
      "dynamodb:*",
      "elasticache:*"
    ]
  }
}
