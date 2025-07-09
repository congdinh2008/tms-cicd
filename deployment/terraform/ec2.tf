# EC2 Instances for TMS applications

# User data script for server instance
locals {
  server_user_data = base64encode(templatefile("${path.module}/scripts/server-init.sh", {
    DOCKERHUB_USERNAME     = var.dockerhub_username
    SERVER_IMAGE_TAG       = var.server_image_tag
    SERVER_PORT            = var.server_port
    ENVIRONMENT            = var.environment
    ENABLE_CLOUDWATCH_LOGS = var.create_cloudwatch_resources
  }))

  client_user_data = base64encode(templatefile("${path.module}/scripts/client-init.sh", {
    DOCKERHUB_USERNAME     = var.dockerhub_username
    CLIENT_IMAGE_TAG       = var.client_image_tag
    CLIENT_PORT            = var.client_port
    ENVIRONMENT            = var.environment
    ENABLE_CLOUDWATCH_LOGS = var.create_cloudwatch_resources
  }))
}

# TMS Server Instance
resource "aws_instance" "tms_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.tms_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = aws_subnet.public_subnets[0].id
  iam_instance_profile   = var.create_iam_resources ? aws_iam_instance_profile.ec2_profile[0].name : null

  user_data                   = local.server_user_data
  user_data_replace_on_change = true

  monitoring = var.enable_monitoring

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true

    tags = merge(local.common_tags, {
      Name = "${var.project_name}-server-root-volume-${var.environment}"
    })
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-server-${var.environment}"
    Type = "Application"
    Role = "Server"
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      user_data,
      ami
    ]
  }
}

# TMS Client Instance
resource "aws_instance" "tms_client" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.tms_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = aws_subnet.public_subnets[1].id
  iam_instance_profile   = var.create_iam_resources ? aws_iam_instance_profile.ec2_profile[0].name : null

  user_data                   = local.client_user_data
  user_data_replace_on_change = true

  monitoring = var.enable_monitoring

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true

    tags = merge(local.common_tags, {
      Name = "${var.project_name}-client-root-volume-${var.environment}"
    })
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-client-${var.environment}"
    Type = "Application"
    Role = "Client"
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      user_data,
      ami
    ]
  }
}

# Elastic IPs for stable public IPs
resource "aws_eip" "server_eip" {
  instance = aws_instance.tms_server.id
  domain   = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-server-eip-${var.environment}"
  })

  depends_on = [aws_internet_gateway.tms_igw]
}

resource "aws_eip" "client_eip" {
  instance = aws_instance.tms_client.id
  domain   = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-client-eip-${var.environment}"
  })

  depends_on = [aws_internet_gateway.tms_igw]
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "server_logs" {
  count = var.create_cloudwatch_resources ? 1 : 0

  name              = "/aws/ec2/${var.project_name}-server-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-server-logs-${var.environment}"
  })
}

resource "aws_cloudwatch_log_group" "client_logs" {
  count = var.create_cloudwatch_resources ? 1 : 0

  name              = "/aws/ec2/${var.project_name}-client-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-client-logs-${var.environment}"
  })
}

# CloudWatch alarms for monitoring
resource "aws_cloudwatch_metric_alarm" "server_cpu_high" {
  count = var.create_cloudwatch_resources ? 1 : 0

  alarm_name          = "${var.project_name}-server-cpu-high-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors server cpu utilization"
  alarm_actions       = [] # Add SNS topic ARN for notifications

  dimensions = {
    InstanceId = aws_instance.tms_server.id
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "client_cpu_high" {
  count = var.create_cloudwatch_resources ? 1 : 0

  alarm_name          = "${var.project_name}-client-cpu-high-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors client cpu utilization"
  alarm_actions       = [] # Add SNS topic ARN for notifications

  dimensions = {
    InstanceId = aws_instance.tms_client.id
  }

  tags = local.common_tags
}
