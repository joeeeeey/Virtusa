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

variable "private_app_subnet_ids" {
  description = "List of private app subnet IDs for the EC2 instances."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ID of the security group for the ALB."
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the target group to attach the ASG to."
  type        = string
}

# Temporarily commented out while not using Secrets Manager
# variable "db_secret_arn" {
#   description = "ARN of the Secrets Manager secret for the DB credentials."
#   type        = string
# }

variable "db_host" {
  description = "Database host endpoint."
  type        = string
}

variable "db_password" {
  description = "Database password."
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name."
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instances."
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "Minimum number of instances in the ASG."
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum number of instances in the ASG."
  type        = number
  default     = 4
}

variable "asg_target_cpu" {
  description = "Target CPU utilization for auto scaling."
  type        = number
  default     = 50.0
}

variable "app_port" {
  description = "Port the application is running on."
  type        = number
  default     = 3000
} 