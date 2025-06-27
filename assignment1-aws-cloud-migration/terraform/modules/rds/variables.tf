variable "project_name" {
  description = "Symbiosis-AWS-Migration"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "db_subnet_ids" {
  description = "List of subnet IDs for the RDS database."
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC where to create the resources."
  type        = string
}

variable "db_instance_class" {
  description = "Instance class for the RDS database."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for the RDS database."
  type        = number
  default     = 20
}

variable "db_multi_az" {
  description = "Specifies if the RDS instance is multi-AZ."
  type        = bool
  default     = false
} 