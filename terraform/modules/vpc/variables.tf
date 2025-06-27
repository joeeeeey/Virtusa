variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_name" {
  description = "Symbiosis-AWS-Migration"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default     = {}
} 