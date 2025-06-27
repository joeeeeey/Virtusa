variable "project_name" {
  description = "Symbiosis-AWS-Migration"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "ID of the VPC where to create the resources."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB."
  type        = list(string)
}

variable "health_check_path" {
  description = "Health check path for the target group."
  type        = string
  default     = "/"
}

variable "app_port" {
  description = "Port the application is running on."
  type        = number
  default     = 3000
} 