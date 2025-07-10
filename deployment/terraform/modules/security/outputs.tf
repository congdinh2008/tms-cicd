# Security Module Outputs

output "web_security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = var.enable_database_sg ? aws_security_group.database[0].id : null
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = var.enable_alb_sg ? aws_security_group.alb[0].id : null
}

output "ec2_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = var.create_iam_resources ? aws_iam_role.ec2_role[0].arn : null
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = var.create_iam_resources ? aws_iam_instance_profile.ec2_profile[0].name : null
}

output "key_pair_name" {
  description = "Name of the EC2 key pair"
  value       = var.create_key_pair ? aws_key_pair.main[0].key_name : null
}

output "kms_key_id" {
  description = "ID of the KMS key"
  value       = var.enable_kms ? aws_kms_key.main[0].key_id : null
}

output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = var.enable_kms ? aws_kms_key.main[0].arn : null
}

output "secrets_manager_secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = var.enable_secrets_manager ? aws_secretsmanager_secret.app_secrets[0].arn : null
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = var.enable_waf ? aws_wafv2_web_acl.main[0].arn : null
}
