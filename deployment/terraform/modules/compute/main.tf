# Compute Module - EC2 Instances, ASG, Launch Templates
# Scalable compute resources for TMS

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Launch Template for Server
resource "aws_launch_template" "server" {
  count = var.enable_auto_scaling ? 1 : 0

  name_prefix   = "${var.name_prefix}-server-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [var.security_group_id]

  user_data = base64encode(templatefile("${path.module}/user-data/server-init.sh", {
    DOCKERHUB_USERNAME     = var.dockerhub_username
    SERVER_IMAGE_TAG       = var.server_image_tag
    SERVER_PORT            = var.server_port
    ENVIRONMENT            = var.environment
    ENABLE_CLOUDWATCH_LOGS = var.enable_cloudwatch_logs
  }))

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = var.kms_key_id
    }
  }

  monitoring {
    enabled = var.enable_monitoring
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${var.name_prefix}-server"
      Role = "Server"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.common_tags, {
      Name = "${var.name_prefix}-server-volume"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Launch Template for Client
resource "aws_launch_template" "client" {
  count = var.enable_auto_scaling ? 1 : 0

  name_prefix   = "${var.name_prefix}-client-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [var.security_group_id]

  user_data = base64encode(templatefile("${path.module}/user-data/client-init.sh", {
    DOCKERHUB_USERNAME     = var.dockerhub_username
    CLIENT_IMAGE_TAG       = var.client_image_tag
    CLIENT_PORT            = var.client_port
    ENVIRONMENT            = var.environment
    ENABLE_CLOUDWATCH_LOGS = var.enable_cloudwatch_logs
  }))

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = var.kms_key_id
    }
  }

  monitoring {
    enabled = var.enable_monitoring
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${var.name_prefix}-client"
      Role = "Client"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.common_tags, {
      Name = "${var.name_prefix}-client-volume"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group for Server
resource "aws_autoscaling_group" "server" {
  count = var.enable_auto_scaling ? 1 : 0

  name                      = "${var.name_prefix}-server-asg"
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = var.server_target_group_arns
  health_check_type         = "ELB"
  health_check_grace_period = 300

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.server[0].id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-server-asg"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}

# Auto Scaling Group for Client
resource "aws_autoscaling_group" "client" {
  count = var.enable_auto_scaling ? 1 : 0

  name                      = "${var.name_prefix}-client-asg"
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = var.client_target_group_arns
  health_check_type         = "ELB"
  health_check_grace_period = 300

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.client[0].id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-client-asg"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}

# Standalone Server Instance (for non-ASG deployment)
resource "aws_instance" "server" {
  count = var.enable_auto_scaling ? 0 : 1

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]
  subnet_id              = var.subnet_ids[0]
  iam_instance_profile   = var.iam_instance_profile_name

  user_data = base64encode(templatefile("${path.module}/user-data/server-init.sh", {
    DOCKERHUB_USERNAME     = var.dockerhub_username
    SERVER_IMAGE_TAG       = var.server_image_tag
    SERVER_PORT            = var.server_port
    ENVIRONMENT            = var.environment
    ENABLE_CLOUDWATCH_LOGS = var.enable_cloudwatch_logs
  }))

  monitoring = var.enable_monitoring

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = var.kms_key_id
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-server"
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

# Standalone Client Instance (for non-ASG deployment)
resource "aws_instance" "client" {
  count = var.enable_auto_scaling ? 0 : 1

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]
  subnet_id              = var.subnet_ids[1]
  iam_instance_profile   = var.iam_instance_profile_name

  user_data = base64encode(templatefile("${path.module}/user-data/client-init.sh", {
    DOCKERHUB_USERNAME     = var.dockerhub_username
    CLIENT_IMAGE_TAG       = var.client_image_tag
    CLIENT_PORT            = var.client_port
    ENVIRONMENT            = var.environment
    ENABLE_CLOUDWATCH_LOGS = var.enable_cloudwatch_logs
  }))

  monitoring = var.enable_monitoring

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = var.kms_key_id
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-client"
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

# Elastic IPs for standalone instances
resource "aws_eip" "server" {
  count = var.enable_auto_scaling ? 0 : 1

  instance = aws_instance.server[0].id
  domain   = "vpc"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-server-eip"
  })
}

resource "aws_eip" "client" {
  count = var.enable_auto_scaling ? 0 : 1

  instance = aws_instance.client[0].id
  domain   = "vpc"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-client-eip"
  })
}

# Auto Scaling Policies
resource "aws_autoscaling_policy" "server_scale_up" {
  count = var.enable_auto_scaling ? 1 : 0

  name                   = "${var.name_prefix}-server-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.server[0].name
}

resource "aws_autoscaling_policy" "server_scale_down" {
  count = var.enable_auto_scaling ? 1 : 0

  name                   = "${var.name_prefix}-server-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.server[0].name
}

resource "aws_autoscaling_policy" "client_scale_up" {
  count = var.enable_auto_scaling ? 1 : 0

  name                   = "${var.name_prefix}-client-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.client[0].name
}

resource "aws_autoscaling_policy" "client_scale_down" {
  count = var.enable_auto_scaling ? 1 : 0

  name                   = "${var.name_prefix}-client-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.client[0].name
}
