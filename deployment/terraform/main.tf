# Main Terraform configuration for TMS infrastructure
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend configuration for remote state (optional)
  # Uncomment and configure for production use
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "tms/terraform.tfstate"
  #   region         = "ap-southeast-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# Local values
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner
    CostCenter  = var.cost_center
  }
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  name_prefix          = local.name_prefix
  common_tags          = local.common_tags
  region               = var.aws_region
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  enable_vpc_endpoints = var.enable_vpc_endpoints
  enable_network_acls  = var.enable_network_acls
}

# Security Module
module "security" {
  source = "./modules/security"

  name_prefix          = local.name_prefix
  common_tags          = local.common_tags
  region               = var.aws_region
  vpc_id               = module.networking.vpc_id
  create_iam_resources = var.create_iam_resources
  create_key_pair      = true
  public_key_material  = var.public_key_material
  enable_kms           = var.enable_kms
  enable_waf           = var.enable_waf

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP access"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS access"
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Spring Boot application"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.allowed_ssh_cidr]
      description = "SSH access"
    }
  ]
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  name_prefix               = local.name_prefix
  common_tags               = local.common_tags
  environment               = var.environment
  enable_auto_scaling       = var.enable_auto_scaling
  instance_type             = var.instance_type
  key_name                  = module.security.key_pair_name
  security_group_id         = module.security.web_security_group_id
  subnet_ids                = module.networking.public_subnet_ids
  iam_instance_profile_name = module.security.ec2_instance_profile_name
  enable_monitoring         = var.enable_monitoring
  root_volume_size          = var.root_volume_size
  kms_key_id                = module.security.kms_key_id
  dockerhub_username        = var.dockerhub_username
  server_image_tag          = var.server_image_tag
  client_image_tag          = var.client_image_tag
  server_port               = var.server_port
  client_port               = var.client_port
  enable_cloudwatch_logs    = var.enable_cloudwatch_logs
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  name_prefix          = local.name_prefix
  common_tags          = local.common_tags
  region               = var.aws_region
  enable_cloudwatch    = var.enable_cloudwatch_logs
  enable_alerting      = var.enable_alerting
  enable_health_checks = var.enable_health_checks
  log_retention_days   = var.log_retention_days
  alert_email          = var.alert_email
  server_instance_id   = module.compute.server_instance_id
  client_instance_id   = module.compute.client_instance_id
  server_public_ip     = module.compute.server_public_ip
  client_public_ip     = module.compute.client_public_ip
  server_port          = var.server_port
  cpu_threshold        = var.cpu_threshold
  memory_threshold     = var.memory_threshold
  disk_threshold       = var.disk_threshold
  error_threshold      = var.error_threshold
}
