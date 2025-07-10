# Monitoring Module Outputs

output "server_log_group_name" {
  description = "Name of the server CloudWatch log group"
  value       = var.enable_cloudwatch ? aws_cloudwatch_log_group.server_logs[0].name : null
}

output "client_log_group_name" {
  description = "Name of the client CloudWatch log group"
  value       = var.enable_cloudwatch ? aws_cloudwatch_log_group.client_logs[0].name : null
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = var.enable_alerting ? aws_sns_topic.alerts[0].arn : null
}

output "dashboard_url" {
  description = "URL to the CloudWatch dashboard"
  value       = var.enable_cloudwatch ? "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=${var.name_prefix}-dashboard" : null
}

output "server_health_check_id" {
  description = "ID of the server health check"
  value       = var.enable_health_checks && var.server_public_ip != null ? aws_route53_health_check.server[0].id : null
}

output "client_health_check_id" {
  description = "ID of the client health check"
  value       = var.enable_health_checks && var.client_public_ip != null ? aws_route53_health_check.client[0].id : null
}

output "cloudwatch_log_groups" {
  description = "List of CloudWatch log groups"
  value = var.enable_cloudwatch ? [
    aws_cloudwatch_log_group.server_logs[0].name,
    aws_cloudwatch_log_group.client_logs[0].name
  ] : []
}

output "alarm_names" {
  description = "List of CloudWatch alarm names"
  value = var.enable_cloudwatch ? [
    var.server_instance_id != null ? aws_cloudwatch_metric_alarm.server_cpu_high[0].alarm_name : null,
    var.client_instance_id != null ? aws_cloudwatch_metric_alarm.client_cpu_high[0].alarm_name : null
  ] : []
}
