variable "aws_region" {
  description = "AWS region for the deployment."
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Symbiosis-AWS-Migration"
  type        = string
  default     = "symbiosis-dev"
}

variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default = {
    "Project"     = "Symbiosis"
    "Environment" = "Dev"
    "ManagedBy"   = "Terraform"
  }
} 