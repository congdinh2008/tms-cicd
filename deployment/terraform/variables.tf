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
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "tms"
}

# Feature flags
variable "create_iam_resources" {
  description = "Whether to create IAM roles and instance profiles (requires IAM permissions)"
  type        = bool
  default     = false
}

variable "create_cloudwatch_resources" {
  description = "Whether to create CloudWatch log groups and alarms (requires CloudWatch permissions)"
  type        = bool
  default     = false
}

# Networking variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
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
  default     = "0.0.0.0/0"  # Change this to your IP range for better security
}

# EC2 variables
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"  # Free tier eligible
}

variable "public_key_material" {
  description = "SSH public key material for EC2 instances"
  type        = string
  default     = ""  # You need to provide this
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring for EC2 instances"
  type        = bool
  default     = true
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

# Application Load Balancer variables
variable "enable_alb" {
  description = "Enable Application Load Balancer"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Health check path for load balancer"
  type        = string
  default     = "/actuator/health"
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

# Database variables (for future RDS integration)
variable "enable_rds" {
  description = "Enable RDS database"
  type        = bool
  default     = false
}

variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS in GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "tmsdb"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

# Backup and maintenance variables
variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "maintenance_window" {
  description = "Maintenance window for RDS"
  type        = string
  default     = "sun:03:00-sun:04:00"
}

variable "backup_window" {
  description = "Backup window for RDS"
  type        = string
  default     = "02:00-03:00"
}

# CloudWatch and monitoring variables
variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

# SSL/TLS variables
variable "enable_ssl" {
  description = "Enable SSL/TLS certificate"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Domain name for SSL certificate"
  type        = string
  default     = ""
}

# Tags
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
