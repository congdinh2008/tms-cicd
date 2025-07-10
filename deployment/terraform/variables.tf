# Variables for TMS Terraform infrastructure

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "tms"
}

variable "owner" {
  description = "Project owner"
  type        = string
  default     = "DevOps Team"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "Engineering"
}

# Feature flags
variable "create_iam_resources" {
  description = "Whether to create IAM roles and instance profiles"
  type        = bool
  default     = true
}

variable "enable_auto_scaling" {
  description = "Enable Auto Scaling Groups instead of standalone instances"
  type        = bool
  default     = false
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = false
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints for cost optimization"
  type        = bool
  default     = false
}

variable "enable_network_acls" {
  description = "Enable Network ACLs for additional security"
  type        = bool
  default     = false
}

variable "enable_kms" {
  description = "Enable KMS encryption"
  type        = bool
  default     = true
}

variable "enable_waf" {
  description = "Enable AWS WAF"
  type        = bool
  default     = false
}

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs"
  type        = bool
  default     = true
}

variable "enable_alerting" {
  description = "Enable SNS alerting"
  type        = bool
  default     = false
}

variable "enable_health_checks" {
  description = "Enable Route53 health checks"
  type        = bool
  default     = false
}

# Networking variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH to instances"
  type        = string
  default     = "0.0.0.0/0"
}

# EC2 variables
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t2.micro", "t2.small", "t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Instance type must be a valid EC2 instance type."
  }
}

variable "public_key_material" {
  description = "SSH public key material for EC2 instances"
  type        = string
  default     = ""
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring for EC2 instances"
  type        = bool
  default     = true
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 100
    error_message = "Root volume size must be between 8 and 100 GB."
  }
}

# Application variables
variable "server_port" {
  description = "Port for the TMS server application"
  type        = number
  default     = 8080
}

variable "client_port" {
  description = "Port for the TMS client application"
  type        = number
  default     = 80
}

# Auto Scaling variables
variable "min_size" {
  description = "Minimum number of instances in Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in Auto Scaling Group"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances in Auto Scaling Group"
  type        = number
  default     = 1
}

# Docker Hub variables
variable "dockerhub_username" {
  description = "Docker Hub username"
  type        = string
  default     = ""
}

variable "server_image_tag" {
  description = "Docker image tag for TMS server"
  type        = string
  default     = "latest"
}

variable "client_image_tag" {
  description = "Docker image tag for TMS client"
  type        = string
  default     = "latest"
}

# Monitoring variables
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch retention value."
  }
}

variable "alert_email" {
  description = "Email address for alerts"
  type        = string
  default     = ""

  validation {
    condition     = var.alert_email == "" || can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.alert_email))
    error_message = "Alert email must be a valid email address."
  }
}

# Alarm thresholds
variable "cpu_threshold" {
  description = "CPU utilization threshold for alarms"
  type        = number
  default     = 80

  validation {
    condition     = var.cpu_threshold >= 1 && var.cpu_threshold <= 100
    error_message = "CPU threshold must be between 1 and 100."
  }
}

variable "memory_threshold" {
  description = "Memory utilization threshold for alarms"
  type        = number
  default     = 80

  validation {
    condition     = var.memory_threshold >= 1 && var.memory_threshold <= 100
    error_message = "Memory threshold must be between 1 and 100."
  }
}

variable "disk_threshold" {
  description = "Disk utilization threshold for alarms"
  type        = number
  default     = 80

  validation {
    condition     = var.disk_threshold >= 1 && var.disk_threshold <= 100
    error_message = "Disk threshold must be between 1 and 100."
  }
}

variable "error_threshold" {
  description = "Error count threshold for alarms"
  type        = number
  default     = 10

  validation {
    condition     = var.error_threshold >= 0
    error_message = "Error threshold must be non-negative."
  }
}
