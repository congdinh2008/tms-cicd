# Security Module - Security Groups, IAM Roles, Key Pairs
# Centralized security configuration for TMS

# Web Security Group
resource "aws_security_group" "web" {
  name_prefix = "${var.name_prefix}-web-sg-"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-web-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Database Security Group
resource "aws_security_group" "database" {
  count = var.enable_database_sg ? 1 : 0

  name_prefix = "${var.name_prefix}-db-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.database_port
    to_port         = var.database_port
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
    description     = "Database access from web servers"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-db-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ALB Security Group
resource "aws_security_group" "alb" {
  count = var.enable_alb_sg ? 1 : 0

  name_prefix = "${var.name_prefix}-alb-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-alb-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# IAM Role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  count = var.create_iam_resources ? 1 : 0

  name = "${var.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# IAM Policy for EC2 instances
resource "aws_iam_role_policy" "ec2_policy" {
  count = var.create_iam_resources ? 1 : 0

  name = "${var.name_prefix}-ec2-policy"
  role = aws_iam_role.ec2_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect = "Allow"
          Action = [
            "ssm:GetParameter",
            "ssm:GetParameters",
            "ssm:GetParametersByPath",
            "ssm:UpdateInstanceInformation",
            "ssm:SendCommand"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"
          ]
          Resource = "arn:aws:logs:${var.region}:*:*"
        }
      ],
      var.additional_iam_policies
    )
  })
}

# Attach AWS managed policies
resource "aws_iam_role_policy_attachment" "ec2_ssm_policy" {
  count = var.create_iam_resources ? 1 : 0

  role       = aws_iam_role.ec2_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_policy" {
  count = var.create_iam_resources ? 1 : 0

  role       = aws_iam_role.ec2_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  count = var.create_iam_resources ? 1 : 0

  name = "${var.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2_role[0].name

  tags = var.common_tags
}

# Key Pair
resource "aws_key_pair" "main" {
  count = var.create_key_pair ? 1 : 0

  key_name   = "${var.name_prefix}-key"
  public_key = var.public_key_material

  tags = var.common_tags
}

# KMS Key for encryption
resource "aws_kms_key" "main" {
  count = var.enable_kms ? 1 : 0

  description             = "KMS key for ${var.name_prefix} encryption"
  deletion_window_in_days = var.kms_deletion_window

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-kms-key"
  })
}

resource "aws_kms_alias" "main" {
  count = var.enable_kms ? 1 : 0

  name          = "alias/${var.name_prefix}-key"
  target_key_id = aws_kms_key.main[0].key_id
}

# Secrets Manager for sensitive data
resource "aws_secretsmanager_secret" "app_secrets" {
  count = var.enable_secrets_manager ? 1 : 0

  name        = "${var.name_prefix}-app-secrets"
  description = "Application secrets for ${var.name_prefix}"

  tags = var.common_tags
}

# WAF Web ACL (optional)
resource "aws_wafv2_web_acl" "main" {
  count = var.enable_waf ? 1 : 0

  name  = "${var.name_prefix}-web-acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name_prefix}CommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  tags = var.common_tags

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name_prefix}WebACL"
    sampled_requests_enabled   = true
  }
}
