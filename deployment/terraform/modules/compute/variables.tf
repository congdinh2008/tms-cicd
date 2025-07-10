# Compute Module Variables

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "enable_auto_scaling" {
  description = "Enable Auto Scaling Groups instead of standalone instances"
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for instances"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for instances"
  type        = list(string)
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = true
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

variable "dockerhub_username" {
  description = "Docker Hub username"
  type        = string
  default     = ""
}

variable "server_image_tag" {
  description = "Docker image tag for server"
  type        = string
  default     = "latest"
}

variable "client_image_tag" {
  description = "Docker image tag for client"
  type        = string
  default     = "latest"
}

variable "server_port" {
  description = "Server application port"
  type        = number
  default     = 8080
}

variable "client_port" {
  description = "Client application port"
  type        = number
  default     = 80
}

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs"
  type        = bool
  default     = true
}

# Auto Scaling variables
variable "min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 1
}

variable "server_target_group_arns" {
  description = "Target group ARNs for server ASG"
  type        = list(string)
  default     = []
}

variable "client_target_group_arns" {
  description = "Target group ARNs for client ASG"
  type        = list(string)
  default     = []
}
