# filepath: d:\CLOUD.DEVOPS RESUMES\project 2 internship\modules\ec2-test\main.tf
# EC2 Test Module for Tag Governance Validation
# This module creates a test EC2 instance with required tags to validate the enforcement

# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  count       = var.enabled ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Get default VPC
data "aws_vpc" "default" {
  count   = var.enabled ? 1 : 0
  default = true
}

# Get the default subnets in the default VPC, then pick a stable first subnet.
data "aws_subnets" "default" {
  count = var.enabled ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default[0].id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

data "aws_subnet" "selected" {
  count = var.enabled ? 1 : 0
  id    = sort(data.aws_subnets.default[0].ids)[0]
}

# Security group for test instance
resource "aws_security_group" "test_instance" {
  count       = var.enabled ? 1 : 0
  name        = var.security_group_name
  description = "Security group for tag governance test instance"
  vpc_id      = data.aws_vpc.default[0].id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "${var.instance_name}-sg"
    emailID     = var.owner_email
    phoneNo     = var.owner_phone
    Place       = var.owner_place
    Environment = var.environment
  })
}

# EC2 instance with required tags
resource "aws_instance" "test_instance" {
  count         = var.enabled ? 1 : 0
  ami           = data.aws_ami.amazon_linux[0].id
  instance_type = var.instance_type
  subnet_id     = data.aws_subnet.selected[0].id

  vpc_security_group_ids = [aws_security_group.test_instance[0].id]

  # Required tags for governance
  tags = merge(var.tags, {
    Name        = var.instance_name
    emailID     = var.owner_email
    phoneNo     = var.owner_phone
    Place       = var.owner_place
    Environment = var.environment
    CostCenter  = var.cost_center
    Owner       = var.owner_name
  })

  lifecycle {
    # Prevent accidental deletion for production-like testing
    # Note: prevent_destroy is set statically, not via variable
    create_before_destroy = true
  }
}

# EBS volume with required tags
resource "aws_ebs_volume" "test_volume" {
  count             = var.enabled ? 1 : 0
  availability_zone = data.aws_subnet.selected[0].availability_zone
  size              = var.volume_size
  type              = var.volume_type

  tags = merge(var.tags, {
    Name        = "${var.instance_name}-volume"
    emailID     = var.owner_email
    phoneNo     = var.owner_phone
    Place       = var.owner_place
    Environment = var.environment
    CostCenter  = var.cost_center
  })

  lifecycle {
    # Note: prevent_destroy is set statically, not via variable
  }
}

# Attach EBS volume to instance
resource "aws_volume_attachment" "test_volume_attachment" {
  count       = var.enabled ? 1 : 0
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.test_volume[0].id
  instance_id = aws_instance.test_instance[0].id
}
