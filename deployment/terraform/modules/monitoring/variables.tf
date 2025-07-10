# Monitoring Module Variables

variable "name_prefix" {
  description = "Prefix for naming resources"
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

variable "enable_cloudwatch" {
  description = "Enable CloudWatch monitoring"
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

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "alert_email" {
  description = "Email address for alerts"
  type        = string
  default     = ""
}

variable "server_instance_id" {
  description = "Server instance ID for monitoring"
  type        = string
  default     = ""
}

variable "client_instance_id" {
  description = "Client instance ID for monitoring"
  type        = string
  default     = ""
}

variable "server_public_ip" {
  description = "Server public IP for health checks"
  type        = string
  default     = ""
}

variable "client_public_ip" {
  description = "Client public IP for health checks"
  type        = string
  default     = ""
}

variable "server_port" {
  description = "Server application port"
  type        = number
  default     = 8080
}

# Alarm thresholds
variable "cpu_threshold" {
  description = "CPU utilization threshold for alarms"
  type        = number
  default     = 80
}

variable "memory_threshold" {
  description = "Memory utilization threshold for alarms"
  type        = number
  default     = 80
}

variable "disk_threshold" {
  description = "Disk utilization threshold for alarms"
  type        = number
  default     = 80
}

variable "error_threshold" {
  description = "Error count threshold for alarms"
  type        = number
  default     = 10
}
