# AWS Tag Governance Enforcement

Terraform project for enforcing AWS tagging standards with layered controls:

- IAM policy guardrails inside a single account
- Service Control Policy (SCP) guardrails across AWS Organizations
- AWS Tag Policy reporting for compliance visibility
- An optional EC2 validation module for end-to-end testing

## Overview

The configuration enforces four required tags across supported resources:

- `Name`
- `emailID`
- `phoneNo`
- `Place`

It also supports recommended governance tags such as `Environment`, `CostCenter`, `Owner`, and `Project`.

## Project Structure

```text
.
├── backend.hcl.example
├── main.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars
├── variables.tf
├── modules
│   ├── ec2-test
│   ├── iam
│   ├── scp
│   └── tag-policy
└── policies
    └── iam-deny-tag-policy.json
```

## Governance Strategy

This project uses a layered governance model so that tag compliance is not dependent on a single control point.

1. IAM policy enforcement protects individual AWS accounts.
   The IAM module blocks create operations when required tags are missing and prevents removal of protected tag keys.

2. SCP enforcement extends the same guardrails to AWS Organizations.
   When enabled, the SCP applies deny rules at the organization level so account administrators cannot bypass them locally.

3. Tag Policy reporting standardizes the schema and highlights drift.
   The tag-policy module uses AWS Organizations tag-policy syntax to report required tags for supported resource types and to standardize recommended keys such as `Environment` and `CostCenter`.

4. Optional validation infrastructure proves the controls.
   The EC2 test module can create a tagged instance, volume, and security group to validate the governance flow in a real account.

## Policy Logic Explanation

The enforcement logic is now aligned with how AWS actually evaluates tag conditions.

### IAM module

- Create actions are denied when any required tag key is missing.
- Tag deletion or mutation is denied when the request touches one of the protected keys in `required_tag_keys`.
- Instance stop and terminate actions are denied when the protected resource tags are missing.
- If `required_tag_value` is set to a real value instead of `*`, the module also enforces that exact value for `required_tag_key`.
- The exemption role pattern remains available for controlled break-glass access.

### SCP module

- The SCP mirrors the same required-tag presence checks used by the IAM module.
- Required-tag deletion is blocked at the organization level.
- Lifecycle operations on governed EC2 resources are denied when required resource tags are missing.
- `enforce_tag_limits` is intentionally blocked and must remain `false` because AWS SCPs do not provide a reliable numeric tag-count condition key.

### Tag Policy module

- The module uses valid AWS Organizations tag-policy syntax with `tag_key` and `report_required_tag_for`.
- Required tag keys are reported for the configured resource types such as `ec2:instance`, `s3:bucket`, and `lambda:function`.
- Recommended tags define standard key casing and, for `Environment`, an approved value set of `dev`, `staging`, `prod`, and `test`.

### EC2 test module

- `enable_ec2_test = false` now truly disables the module's resources and data lookups.
- Default subnet discovery was corrected so the module selects a stable default subnet instead of failing on multiple matches.

## Cost Management Benefits

Strong tagging directly improves FinOps and cost control.

1. Better allocation.
   `CostCenter`, `Environment`, and owner-related tags make AWS Cost Explorer, CUR analysis, and chargeback/showback reports much easier to trust.

2. Faster accountability.
   When every resource has ownership metadata, teams can identify who created a resource, who pays for it, and who should clean it up.

3. Lower waste.
   Untagged or mis-tagged infrastructure is usually the hardest to optimize. These controls reduce orphaned resources and make cleanup campaigns more effective.

4. Safer reporting.
   Standardized tag keys and values reduce dashboard noise caused by casing drift such as `environment`, `Environment`, and `ENVIRONMENT`.

## Key Configuration Notes

Important variables in `terraform.tfvars`:

- `enable_iam_enforcement`: enables account-level deny policies
- `enable_scp_enforcement`: enables organization-level SCP enforcement
- `enable_tag_policy`: enables AWS Tag Policy reporting
- `enable_ec2_test`: enables the optional test stack
- `required_tag_keys`: protected mandatory tag keys
- `required_tag_key` and `required_tag_value`: optional exact-value enforcement for one primary tag
- `tag_policy_resource_types`: resource identifiers used by AWS Organizations tag policies

Keep these constraints in mind:

- `enable_scp_enforcement` and `enable_tag_policy` require an AWS Organizations management account or delegated admin context.
- `target_ou_id` is needed when you want Terraform to attach the SCP or tag policy to a specific OU.
- `enable_ec2_test` expects a default VPC and at least one default subnet in the target region.

## Deployment

### 1. Update variables

Edit `terraform.tfvars` with your AWS-specific values.

### 2. Provide backend settings

Terraform backends cannot use input variables. Supply backend settings at init time with a file shaped like `backend.hcl.example`.

Example:

```hcl
bucket         = "terraform-state-123456789012"
key            = "tag-governance/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-state-locking"
```

### 3. Initialize Terraform

```bash
terraform init -backend-config=backend.hcl
```

For local syntax validation without contacting the backend:

```bash
terraform init -backend=false -reconfigure
```

### 4. Validate and plan

```bash
terraform fmt -recursive
terraform validate
terraform plan
```

### 5. Apply

```bash
terraform apply
```

## Validation Scenarios

### Expected success

Create a resource with all required tags.

### Expected failure

Try to create a governed resource without one or more of:

- `Name`
- `emailID`
- `phoneNo`
- `Place`

### Expected failure

Try to remove one of the protected tag keys from an existing governed resource.

### Expected success with exemption flow

Assume the exemption role and perform the same operation for audited break-glass access.

## Real Demo Validation

This project now supports a live AWS demo with:

- a Terraform-created demo instance
- a dedicated demo launch role for real success and failure tests

### 1. Check the deployed demo resources

Run:

```bash
terraform output
```

Look for:

- `test_instance_id`
- `test_security_group_id`
- `launch_demo_role_arn`
- `iam_policy_arn`

### 2. Check the success demo in the AWS console

Open AWS Console and verify:

1. Go to `EC2 > Instances`
2. Search for the instance ID from `test_instance_id`
3. Confirm the instance has these required tags:
   `Name`, `emailID`, `phoneNo`, `Place`
4. Confirm the attached EBS volume also has the required tags

### 3. Run a real tagged launch that should succeed

Assume the demo role:

```bash
aws sts assume-role \
  --role-arn <launch_demo_role_arn> \
  --role-session-name tag-governance-demo
```

Export the temporary credentials and launch with required tags on both the instance and volume:

```bash
aws ec2 run-instances \
  --image-id <ami-id> \
  --instance-type t3.micro \
  --subnet-id <subnet-id> \
  --security-group-ids <security-group-id> \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=tag-demo},{Key=emailID,Value=devops@example.com},{Key=phoneNo,Value=+1-555-0100},{Key=Place,Value=Headquarters}]' \
  'ResourceType=volume,Tags=[{Key=Name,Value=tag-demo-volume},{Key=emailID,Value=devops@example.com},{Key=phoneNo,Value=+1-555-0100},{Key=Place,Value=Headquarters}]'
```

Expected result:

- instance launch succeeds
- instance enters `running`
- tags are visible in `EC2 > Instances`

### 4. Run a real untagged launch that should fail

Using the same assumed role, try:

```bash
aws ec2 run-instances \
  --image-id <ami-id> \
  --instance-type t3.micro \
  --subnet-id <subnet-id> \
  --security-group-ids <security-group-id>
```

Expected result:

- AWS returns `UnauthorizedOperation`
- the error message states there is an explicit deny in `aws-tag-governance-deny-policy`
- no instance is created

### 5. Check proof of success and failure in AWS

For success proof:

1. Go to `EC2 > Instances`
2. Filter by the launched instance name or instance ID
3. Open the `Tags` tab and confirm all four required tags

For failure proof:

1. Go to `CloudTrail > Event history`
2. Filter `Event source = ec2.amazonaws.com`
3. Filter `Event name = RunInstances`
4. Open the failed event and confirm the access-denied message references the tag-governance IAM policy

## Outputs

After a successful apply, Terraform returns values such as:

- current AWS account ID
- IAM policy ARN and exemption role details
- SCP and tag-policy IDs when organization controls are enabled
- EC2 validation resource details when the test module is enabled
- a compliance summary showing which control layers are active

## Notes

- `terraform validate` is useful for configuration correctness, but a full `terraform plan` still requires valid AWS credentials.
- The sample policy JSON in `policies/` is informational; the active IAM policy is generated by the Terraform module logic.
