# Compute Module Outputs

# Standalone Instance Outputs
output "server_instance_id" {
  description = "ID of the server instance"
  value       = var.enable_auto_scaling ? null : aws_instance.server[0].id
}

output "client_instance_id" {
  description = "ID of the client instance"
  value       = var.enable_auto_scaling ? null : aws_instance.client[0].id
}

output "server_public_ip" {
  description = "Public IP of the server instance"
  value       = var.enable_auto_scaling ? null : aws_eip.server[0].public_ip
}

output "client_public_ip" {
  description = "Public IP of the client instance"
  value       = var.enable_auto_scaling ? null : aws_eip.client[0].public_ip
}

output "server_private_ip" {
  description = "Private IP of the server instance"
  value       = var.enable_auto_scaling ? null : aws_instance.server[0].private_ip
}

output "client_private_ip" {
  description = "Private IP of the client instance"
  value       = var.enable_auto_scaling ? null : aws_instance.client[0].private_ip
}

# Auto Scaling Group Outputs
output "server_asg_name" {
  description = "Name of the server Auto Scaling Group"
  value       = var.enable_auto_scaling ? aws_autoscaling_group.server[0].name : null
}

output "client_asg_name" {
  description = "Name of the client Auto Scaling Group"
  value       = var.enable_auto_scaling ? aws_autoscaling_group.client[0].name : null
}

output "server_launch_template_id" {
  description = "ID of the server launch template"
  value       = var.enable_auto_scaling ? aws_launch_template.server[0].id : null
}

output "client_launch_template_id" {
  description = "ID of the client launch template"
  value       = var.enable_auto_scaling ? aws_launch_template.client[0].id : null
}

# Application URLs
output "server_url" {
  description = "URL for the server application"
  value       = var.enable_auto_scaling ? null : "http://${aws_eip.server[0].public_ip}:${var.server_port}"
}

output "client_url" {
  description = "URL for the client application"
  value       = var.enable_auto_scaling ? null : "http://${aws_eip.client[0].public_ip}"
}

output "server_health_check_url" {
  description = "Health check URL for the server"
  value       = var.enable_auto_scaling ? null : "http://${aws_eip.server[0].public_ip}:${var.server_port}/actuator/health"
}

# Auto Scaling Policy ARNs
output "server_scale_up_policy_arn" {
  description = "ARN of server scale up policy"
  value       = var.enable_auto_scaling ? aws_autoscaling_policy.server_scale_up[0].arn : null
}

output "server_scale_down_policy_arn" {
  description = "ARN of server scale down policy"
  value       = var.enable_auto_scaling ? aws_autoscaling_policy.server_scale_down[0].arn : null
}

output "client_scale_up_policy_arn" {
  description = "ARN of client scale up policy"
  value       = var.enable_auto_scaling ? aws_autoscaling_policy.client_scale_up[0].arn : null
}

output "client_scale_down_policy_arn" {
  description = "ARN of client scale down policy"
  value       = var.enable_auto_scaling ? aws_autoscaling_policy.client_scale_down[0].arn : null
}
