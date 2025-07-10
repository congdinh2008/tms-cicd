# Output values for TMS infrastructure

# Module Outputs
output "networking" {
  description = "Networking module outputs"
  value = {
    vpc_id              = module.networking.vpc_id
    vpc_cidr_block      = module.networking.vpc_cidr_block
    public_subnet_ids   = module.networking.public_subnet_ids
    private_subnet_ids  = module.networking.private_subnet_ids
    internet_gateway_id = module.networking.internet_gateway_id
    nat_gateway_ids     = module.networking.nat_gateway_ids
  }
}

output "security" {
  description = "Security module outputs"
  value = {
    web_security_group_id = module.security.web_security_group_id
    key_pair_name         = module.security.key_pair_name
    ec2_role_arn          = module.security.ec2_role_arn
    ec2_instance_profile  = module.security.ec2_instance_profile_name
    kms_key_id            = module.security.kms_key_id
  }
}

output "compute" {
  description = "Compute module outputs"
  value = {
    server_instance_id = module.compute.server_instance_id
    client_instance_id = module.compute.client_instance_id
    server_public_ip   = module.compute.server_public_ip
    client_public_ip   = module.compute.client_public_ip
    server_private_ip  = module.compute.server_private_ip
    client_private_ip  = module.compute.client_private_ip
    server_asg_name    = module.compute.server_asg_name
    client_asg_name    = module.compute.client_asg_name
  }
}

output "monitoring" {
  description = "Monitoring module outputs"
  value = {
    server_log_group      = module.monitoring.server_log_group_name
    client_log_group      = module.monitoring.client_log_group_name
    sns_topic_arn         = module.monitoring.sns_topic_arn
    dashboard_url         = module.monitoring.dashboard_url
    cloudwatch_log_groups = module.monitoring.cloudwatch_log_groups
  }
}

# Legacy Outputs for Backward Compatibility
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.networking.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "web_security_group_id" {
  description = "ID of the web security group"
  value       = module.security.web_security_group_id
}

output "server_instance_id" {
  description = "ID of the TMS server instance"
  value       = module.compute.server_instance_id
}

output "client_instance_id" {
  description = "ID of the TMS client instance"
  value       = module.compute.client_instance_id
}

output "server_public_ip" {
  description = "Public IP address of the TMS server"
  value       = module.compute.server_public_ip
}

output "client_public_ip" {
  description = "Public IP address of the TMS client"
  value       = module.compute.client_public_ip
}

output "server_private_ip" {
  description = "Private IP address of the TMS server"
  value       = module.compute.server_private_ip
}

output "client_private_ip" {
  description = "Private IP address of the TMS client"
  value       = module.compute.client_private_ip
}

# Application URLs
output "server_url" {
  description = "URL for the TMS server application"
  value       = module.compute.server_url
}

output "client_url" {
  description = "URL for the TMS client application"
  value       = module.compute.client_url
}

output "server_health_check_url" {
  description = "Health check URL for the TMS server"
  value       = module.compute.server_health_check_url
}

# SSH connection commands
output "server_ssh_command" {
  description = "SSH command to connect to the server instance"
  value       = module.compute.server_public_ip != null ? "ssh -i ~/.ssh/${module.security.key_pair_name}.pem ec2-user@${module.compute.server_public_ip}" : null
}

output "client_ssh_command" {
  description = "SSH command to connect to the client instance"
  value       = module.compute.client_public_ip != null ? "ssh -i ~/.ssh/${module.security.key_pair_name}.pem ec2-user@${module.compute.client_public_ip}" : null
}

output "key_pair_name" {
  description = "Name of the AWS key pair"
  value       = module.security.key_pair_name
}

output "ec2_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = module.security.ec2_role_arn
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = module.security.ec2_instance_profile_name
}

output "server_log_group_name" {
  description = "Name of the server CloudWatch log group"
  value       = module.monitoring.server_log_group_name
}

output "client_log_group_name" {
  description = "Name of the client CloudWatch log group"
  value       = module.monitoring.client_log_group_name
}

# Deployment information
output "deployment_info" {
  description = "Important deployment information"
  value = {
    region               = var.aws_region
    environment          = var.environment
    project_name         = var.project_name
    server_instance_id   = module.compute.server_instance_id
    client_instance_id   = module.compute.client_instance_id
    server_public_ip     = module.compute.server_public_ip
    client_public_ip     = module.compute.client_public_ip
    vpc_id               = module.networking.vpc_id
    security_group_id    = module.security.web_security_group_id
    key_pair_name        = module.security.key_pair_name
    auto_scaling_enabled = var.enable_auto_scaling
  }
}

# GitHub Actions secrets information
output "github_secrets_info" {
  description = "Information needed for GitHub Actions secrets"
  value = {
    AWS_REGION             = var.aws_region
    EC2_SERVER_INSTANCE_ID = module.compute.server_instance_id
    EC2_CLIENT_INSTANCE_ID = module.compute.client_instance_id
    SERVER_PUBLIC_IP       = module.compute.server_public_ip
    CLIENT_PUBLIC_IP       = module.compute.client_public_ip
    DOCKERHUB_USERNAME_VAR = "Set manually: ${var.dockerhub_username}"
  }
  sensitive = false
}
