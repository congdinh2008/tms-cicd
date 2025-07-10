# Monitoring Module - CloudWatch, Alarms, SNS
# Comprehensive monitoring for TMS infrastructure

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "server_logs" {
  count = var.enable_cloudwatch ? 1 : 0

  name              = "/aws/ec2/${var.name_prefix}-server"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-server-logs"
  })
}

resource "aws_cloudwatch_log_group" "client_logs" {
  count = var.enable_cloudwatch ? 1 : 0

  name              = "/aws/ec2/${var.name_prefix}-client"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-client-logs"
  })
}

# SNS Topic for alerts
resource "aws_sns_topic" "alerts" {
  count = var.enable_alerting ? 1 : 0

  name = "${var.name_prefix}-alerts"

  tags = var.common_tags
}

resource "aws_sns_topic_subscription" "email_alerts" {
  count = var.enable_alerting && var.alert_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# CloudWatch Alarms for Server
resource "aws_cloudwatch_metric_alarm" "server_cpu_high" {
  count = var.enable_cloudwatch ? 1 : 0

  alarm_name          = "${var.name_prefix}-server-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "This metric monitors server cpu utilization"
  alarm_actions       = var.enable_alerting ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions          = var.enable_alerting ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = var.server_instance_id != "" ? {
    InstanceId = var.server_instance_id
  } : {}

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "server_memory_high" {
  count = var.enable_cloudwatch ? 1 : 0

  alarm_name          = "${var.name_prefix}-server-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "mem_used_percent"
  namespace           = "TMS/Server"
  period              = "300"
  statistic           = "Average"
  threshold           = var.memory_threshold
  alarm_description   = "This metric monitors server memory utilization"
  alarm_actions       = var.enable_alerting ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions          = var.enable_alerting ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = var.server_instance_id != "" ? {
    InstanceId = var.server_instance_id
  } : {}

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "server_disk_high" {
  count = var.enable_cloudwatch ? 1 : 0

  alarm_name          = "${var.name_prefix}-server-disk-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "used_percent"
  namespace           = "TMS/Server"
  period              = "300"
  statistic           = "Average"
  threshold           = var.disk_threshold
  alarm_description   = "This metric monitors server disk utilization"
  alarm_actions       = var.enable_alerting ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions          = var.enable_alerting ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = var.server_instance_id != "" ? {
    InstanceId = var.server_instance_id
  } : {}

  tags = var.common_tags
}

# CloudWatch Alarms for Client
resource "aws_cloudwatch_metric_alarm" "client_cpu_high" {
  count = var.enable_cloudwatch ? 1 : 0

  alarm_name          = "${var.name_prefix}-client-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "This metric monitors client cpu utilization"
  alarm_actions       = var.enable_alerting ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions          = var.enable_alerting ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = var.client_instance_id != "" ? {
    InstanceId = var.client_instance_id
  } : {}

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "client_memory_high" {
  count = var.enable_cloudwatch ? 1 : 0

  alarm_name          = "${var.name_prefix}-client-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "mem_used_percent"
  namespace           = "TMS/Client"
  period              = "300"
  statistic           = "Average"
  threshold           = var.memory_threshold
  alarm_description   = "This metric monitors client memory utilization"
  alarm_actions       = var.enable_alerting ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions          = var.enable_alerting ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = var.client_instance_id != "" ? {
    InstanceId = var.client_instance_id
  } : {}

  tags = var.common_tags
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  count = var.enable_cloudwatch ? 1 : 0

  dashboard_name = "${var.name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = concat(
            var.server_instance_id != "" ? [["AWS/EC2", "CPUUtilization", "InstanceId", var.server_instance_id]] : [],
            var.client_instance_id != "" ? [[".", ".", ".", var.client_instance_id]] : []
          )
          period = 300
          stat   = "Average"
          region = var.region
          title  = "EC2 CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = concat(
            var.server_instance_id != "" ? [["TMS/Server", "mem_used_percent", "InstanceId", var.server_instance_id]] : [],
            var.client_instance_id != "" ? [["TMS/Client", "mem_used_percent", "InstanceId", var.client_instance_id]] : []
          )
          period = 300
          stat   = "Average"
          region = var.region
          title  = "Memory Utilization"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 12
        width  = 24
        height = 6

        properties = {
          query  = "SOURCE '/aws/ec2/${var.name_prefix}-server' | fields @timestamp, @message | sort @timestamp desc | limit 100"
          region = var.region
          title  = "Server Logs"
        }
      }
    ]
  })
}

# Custom Metrics for Application Health
resource "aws_cloudwatch_log_metric_filter" "server_errors" {
  count = var.enable_cloudwatch ? 1 : 0

  name           = "${var.name_prefix}-server-errors"
  log_group_name = aws_cloudwatch_log_group.server_logs[0].name
  pattern        = "ERROR"

  metric_transformation {
    name      = "ServerErrorCount"
    namespace = "TMS/Application"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "client_errors" {
  count = var.enable_cloudwatch ? 1 : 0

  name           = "${var.name_prefix}-client-errors"
  log_group_name = aws_cloudwatch_log_group.client_logs[0].name
  pattern        = "ERROR"

  metric_transformation {
    name      = "ClientErrorCount"
    namespace = "TMS/Application"
    value     = "1"
  }
}

# Application Error Alarms
resource "aws_cloudwatch_metric_alarm" "server_error_rate" {
  count = var.enable_cloudwatch ? 1 : 0

  alarm_name          = "${var.name_prefix}-server-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ServerErrorCount"
  namespace           = "TMS/Application"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.error_threshold
  alarm_description   = "This metric monitors server error rate"
  alarm_actions       = var.enable_alerting ? [aws_sns_topic.alerts[0].arn] : []

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "client_error_rate" {
  count = var.enable_cloudwatch ? 1 : 0

  alarm_name          = "${var.name_prefix}-client-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ClientErrorCount"
  namespace           = "TMS/Application"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.error_threshold
  alarm_description   = "This metric monitors client error rate"
  alarm_actions       = var.enable_alerting ? [aws_sns_topic.alerts[0].arn] : []

  tags = var.common_tags
}

# Health Check Alarms (using external health check service)
resource "aws_route53_health_check" "server" {
  count = var.enable_health_checks && var.server_public_ip != null ? 1 : 0

  fqdn                            = var.server_public_ip
  port                            = var.server_port
  type                            = "HTTP"
  resource_path                   = "/actuator/health"
  failure_threshold               = "3"
  request_interval                = "30"
  cloudwatch_alarm_region         = var.region
  cloudwatch_alarm_name           = "${var.name_prefix}-server-health-check"
  insufficient_data_health_status = "LastKnownStatus"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-server-health-check"
  })
}

resource "aws_route53_health_check" "client" {
  count = var.enable_health_checks && var.client_public_ip != null ? 1 : 0

  fqdn                            = var.client_public_ip
  port                            = 80
  type                            = "HTTP"
  resource_path                   = "/health"
  failure_threshold               = "3"
  request_interval                = "30"
  cloudwatch_alarm_region         = var.region
  cloudwatch_alarm_name           = "${var.name_prefix}-client-health-check"
  insufficient_data_health_status = "LastKnownStatus"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-client-health-check"
  })
}
