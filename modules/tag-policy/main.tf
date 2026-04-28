# filepath: d:\CLOUD.DEVOPS RESUMES\project 2 internship\modules\tag-policy\main.tf
# AWS Tag Policy Module for Tag Governance
# Tag Policies help enforce tag standards and provide compliance visibility

# Get organization information
data "aws_organizations_organization" "this" {
  count = var.enabled ? 1 : 0
}

# Tag Policy to enforce required tags and provide compliance visibility
resource "aws_organizations_policy" "tag_policy" {
  count       = var.enabled ? 1 : 0
  name        = var.policy_name
  description = var.policy_description
  type        = "TAG_POLICY"

  content = jsonencode({
    tags = {
      Name = {
        tag_key = {
          "@@assign" = "Name"
        }
        report_required_tag_for = {
          "@@assign" = var.enforced_resource_types
        }
      }
      emailID = {
        tag_key = {
          "@@assign" = "emailID"
        }
        report_required_tag_for = {
          "@@assign" = var.enforced_resource_types
        }
      }
      phoneNo = {
        tag_key = {
          "@@assign" = "phoneNo"
        }
        report_required_tag_for = {
          "@@assign" = var.enforced_resource_types
        }
      }
      Place = {
        tag_key = {
          "@@assign" = "Place"
        }
        report_required_tag_for = {
          "@@assign" = var.enforced_resource_types
        }
      }
    }
  })

  tags = var.tags
}

# Tag Policy for optional tags (recommended but not enforced)
resource "aws_organizations_policy" "recommended_tags" {
  count       = var.enabled && var.create_recommended_policy ? 1 : 0
  name        = "${var.policy_name}-recommended"
  description = "Recommended tags for better resource management"
  type        = "TAG_POLICY"

  content = jsonencode({
    tags = {
      Project = {
        tag_key = {
          "@@assign" = "Project"
        }
      }
      Owner = {
        tag_key = {
          "@@assign" = "Owner"
        }
      }
      Application = {
        tag_key = {
          "@@assign" = "Application"
        }
      }
      Backup = {
        tag_key = {
          "@@assign" = "Backup"
        }
      }
      Compliance = {
        tag_key = {
          "@@assign" = "Compliance"
        }
      }
      Environment = {
        tag_key = {
          "@@assign" = "Environment"
        }
        tag_value = {
          "@@assign" = ["dev", "staging", "prod", "test"]
        }
      }
      CostCenter = {
        tag_key = {
          "@@assign" = "CostCenter"
        }
      }
    }
  })

  tags = var.tags
}

# Attach Tag Policy to organizational units
resource "aws_organizations_policy_attachment" "tag_policy_attachment" {
  count     = var.enabled && var.target_ou_id != "" ? 1 : 0
  policy_id = aws_organizations_policy.tag_policy[0].id
  target_id = var.target_ou_id
}

resource "aws_organizations_policy_attachment" "recommended_tags_attachment" {
  count     = var.enabled && var.create_recommended_policy && var.target_ou_id != "" ? 1 : 0
  policy_id = aws_organizations_policy.recommended_tags[0].id
  target_id = var.target_ou_id
}
