# Output values for TMS infrastructure

# VPC outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.tms_vpc.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.tms_vpc.cidr_block
}

# Subnet outputs
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private_subnets[*].id
}

# Security Group outputs
output "web_security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web_sg.id
}

# EC2 Instance outputs
output "server_instance_id" {
  description = "ID of the TMS server instance"
  value       = aws_instance.tms_server.id
}

output "client_instance_id" {
  description = "ID of the TMS client instance"
  value       = aws_instance.tms_client.id
}

output "server_public_ip" {
  description = "Public IP address of the TMS server"
  value       = aws_eip.server_eip.public_ip
}

output "client_public_ip" {
  description = "Public IP address of the TMS client"
  value       = aws_eip.client_eip.public_ip
}

output "server_private_ip" {
  description = "Private IP address of the TMS server"
  value       = aws_instance.tms_server.private_ip
}

output "client_private_ip" {
  description = "Private IP address of the TMS client"
  value       = aws_instance.tms_client.private_ip
}

# Application URLs
output "server_url" {
  description = "URL for the TMS server application"
  value       = "http://${aws_eip.server_eip.public_ip}:${var.server_port}"
}

output "client_url" {
  description = "URL for the TMS client application"
  value       = "http://${aws_eip.client_eip.public_ip}"
}

output "server_health_check_url" {
  description = "Health check URL for the TMS server"
  value       = "http://${aws_eip.server_eip.public_ip}:${var.server_port}/actuator/health"
}

# SSH connection commands
output "server_ssh_command" {
  description = "SSH command to connect to the server instance"
  value       = "ssh -i ~/.ssh/${aws_key_pair.tms_key.key_name}.pem ec2-user@${aws_eip.server_eip.public_ip}"
}

output "client_ssh_command" {
  description = "SSH command to connect to the client instance"
  value       = "ssh -i ~/.ssh/${aws_key_pair.tms_key.key_name}.pem ec2-user@${aws_eip.client_eip.public_ip}"
}

# Key Pair outputs
output "key_pair_name" {
  description = "Name of the AWS key pair"
  value       = aws_key_pair.tms_key.key_name
}

# IAM outputs
output "ec2_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = var.create_iam_resources ? aws_iam_role.ec2_role[0].arn : null
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = var.create_iam_resources ? aws_iam_instance_profile.ec2_profile[0].name : null
}

# CloudWatch outputs
output "server_log_group_name" {
  description = "Name of the server CloudWatch log group"
  value       = var.create_cloudwatch_resources ? aws_cloudwatch_log_group.server_logs[0].name : null
}

output "client_log_group_name" {
  description = "Name of the client CloudWatch log group"
  value       = var.create_cloudwatch_resources ? aws_cloudwatch_log_group.client_logs[0].name : null
}

# Deployment information
output "deployment_info" {
  description = "Important deployment information"
  value = {
    region                = var.aws_region
    environment          = var.environment
    server_instance_id   = aws_instance.tms_server.id
    client_instance_id   = aws_instance.tms_client.id
    server_public_ip     = aws_eip.server_eip.public_ip
    client_public_ip     = aws_eip.client_eip.public_ip
    vpc_id              = aws_vpc.tms_vpc.id
    security_group_id   = aws_security_group.web_sg.id
  }
}

# GitHub Actions secrets information
output "github_secrets_info" {
  description = "Information needed for GitHub Actions secrets"
  value = {
    AWS_REGION                = var.aws_region
    EC2_SERVER_INSTANCE_ID    = aws_instance.tms_server.id
    EC2_CLIENT_INSTANCE_ID    = aws_instance.tms_client.id
    SERVER_PUBLIC_IP          = aws_eip.server_eip.public_ip
    CLIENT_PUBLIC_IP          = aws_eip.client_eip.public_ip
  }
  sensitive = false
}
