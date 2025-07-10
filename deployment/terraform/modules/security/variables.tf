# Security Module Variables

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules for web security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
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
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH access"
    }
  ]
}

variable "enable_database_sg" {
  description = "Enable database security group"
  type        = bool
  default     = false
}

variable "database_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "enable_alb_sg" {
  description = "Enable ALB security group"
  type        = bool
  default     = false
}

variable "create_iam_resources" {
  description = "Whether to create IAM roles and policies"
  type        = bool
  default     = false
}

variable "additional_iam_policies" {
  description = "Additional IAM policy statements"
  type        = list(any)
  default     = []
}

variable "create_key_pair" {
  description = "Whether to create EC2 key pair"
  type        = bool
  default     = true
}

variable "public_key_material" {
  description = "SSH public key material"
  type        = string
  default     = ""
}

variable "enable_kms" {
  description = "Enable KMS key creation"
  type        = bool
  default     = false
}

variable "kms_deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 7
}

variable "enable_secrets_manager" {
  description = "Enable AWS Secrets Manager"
  type        = bool
  default     = false
}

variable "enable_waf" {
  description = "Enable AWS WAF"
  type        = bool
  default     = false
}
