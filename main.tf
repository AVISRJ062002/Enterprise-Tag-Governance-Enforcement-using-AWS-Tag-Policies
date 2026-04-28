# filepath: d:\CLOUD.DEVOPS RESUMES\project 2 internship\main.tf
# AWS Tag Governance Enforcement - Root Configuration
# This is the main Terraform configuration that orchestrates all modules

terraform {
  # Required version with backend configuration
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend values must be supplied during `terraform init` because backend
  # blocks cannot read input variables.
  backend "s3" {}
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.default_tags
  }

  # Skip validation for resources that may not exist yet
  skip_credentials_validation = false
  skip_requesting_account_id  = false
  skip_metadata_api_check     = false
}

# Get caller identity for current account
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "launch_demo_assume_role" {
  count = var.enable_launch_demo_role ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.arn]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Get the organization (if in an organization)
data "aws_organizations_organization" "org" {
  count = var.is_organization_account ? 1 : 0
}

# =============================================================================
# IAM Module - Tag Enforcement Policy
# =============================================================================
module "iam_tag_enforcement" {
  source = "./modules/iam"

  enabled                 = var.enable_iam_enforcement
  policy_name             = var.iam_policy_name
  policy_description      = "IAM policy to enforce required tags on AWS resources"
  required_tag_key        = var.required_tag_key
  required_tag_value      = var.required_tag_value
  required_tag_keys       = var.required_tag_keys
  enforced_resource_types = var.enforced_resource_types
  exemption_role_pattern  = var.exemption_role_pattern
  create_exemption_role   = var.create_exemption_role
  attach_to_role_name     = var.attach_to_role_name
  tags                    = var.module_tags
}

# =============================================================================
# SCP Module - Service Control Policy (Organization Level)
# =============================================================================
module "scp_tag_enforcement" {
  source = "./modules/scp"

  enabled                 = var.enable_scp_enforcement
  policy_name             = var.scp_policy_name
  policy_description      = "Service Control Policy to enforce required tags at organization level"
  required_tag_key        = var.required_tag_key
  required_tag_value      = var.required_tag_value
  required_tag_keys       = var.required_tag_keys
  enforced_resource_types = var.enforced_resource_types
  enforce_tag_limits      = var.enforce_tag_limits
  max_tag_count           = var.max_tag_count
  target_ou_id            = var.target_ou_id
  exempted_role_patterns  = var.exempted_role_patterns
  tags                    = var.module_tags

  depends_on = [data.aws_organizations_organization.org]
}

# =============================================================================
# Tag Policy Module - AWS Tag Policy for Compliance Visibility
# =============================================================================
module "tag_policy" {
  source = "./modules/tag-policy"

  enabled                   = var.enable_tag_policy
  policy_name               = var.tag_policy_name
  policy_description        = "AWS Tag Policy to enforce required tags and provide compliance visibility"
  target_ou_id              = var.target_ou_id
  enforced_resource_types   = var.tag_policy_resource_types
  create_recommended_policy = var.create_recommended_tags_policy
  tags                      = var.module_tags

  depends_on = [data.aws_organizations_organization.org]
}

# =============================================================================
# EC2 Test Module - Validation Instance
# =============================================================================
module "ec2_test" {
  source = "./modules/ec2-test"

  enabled             = var.enable_ec2_test
  instance_name       = var.test_instance_name
  instance_type       = var.test_instance_type
  security_group_name = var.test_security_group_name
  volume_size         = var.test_volume_size
  volume_type         = var.test_volume_type
  owner_email         = var.owner_email
  owner_phone         = var.owner_phone
  owner_place         = var.owner_place
  owner_name          = var.owner_name
  environment         = var.environment
  cost_center         = var.cost_center
  tags                = var.module_tags
}

resource "aws_iam_role" "launch_demo" {
  count = var.enable_launch_demo_role ? 1 : 0

  name               = var.launch_demo_role_name
  assume_role_policy = data.aws_iam_policy_document.launch_demo_assume_role[0].json
  tags = merge(var.module_tags, {
    Purpose = "TagGovernanceDemo"
  })
}

resource "aws_iam_role_policy_attachment" "launch_demo_ec2_access" {
  count = var.enable_launch_demo_role ? 1 : 0

  role       = aws_iam_role.launch_demo[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "launch_demo_tag_enforcement" {
  count = var.enable_launch_demo_role && var.enable_iam_enforcement ? 1 : 0

  role       = aws_iam_role.launch_demo[0].name
  policy_arn = module.iam_tag_enforcement.policy_arn
}
