# filepath: d:\CLOUD.DEVOPS RESUMES\project 2 internship\modules\ec2-test\outputs.tf
# Outputs for EC2 Test Module

output "instance_id" {
  description = "ID of the test EC2 instance"
  value       = var.enabled ? aws_instance.test_instance[0].id : ""
}

output "instance_arn" {
  description = "ARN of the test EC2 instance"
  value       = var.enabled ? aws_instance.test_instance[0].arn : ""
}

output "instance_public_ip" {
  description = "Public IP address of the test EC2 instance"
  value       = var.enabled ? aws_instance.test_instance[0].public_ip : ""
}

output "instance_private_ip" {
  description = "Private IP address of the test EC2 instance"
  value       = var.enabled ? aws_instance.test_instance[0].private_ip : ""
}

output "security_group_id" {
  description = "ID of the security group"
  value       = var.enabled ? aws_security_group.test_instance[0].id : ""
}

output "volume_id" {
  description = "ID of the EBS volume"
  value       = var.enabled ? aws_ebs_volume.test_volume[0].id : ""
}

output "ami_id" {
  description = "ID of the AMI used"
  value       = var.enabled ? data.aws_ami.amazon_linux[0].id : ""
}

output "instance_tags" {
  description = "Tags applied to the instance"
  value       = var.enabled ? aws_instance.test_instance[0].tags : {}
}

output "volume_tags" {
  description = "Tags applied to the volume"
  value       = var.enabled ? aws_ebs_volume.test_volume[0].tags : {}
}
