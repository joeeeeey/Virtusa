# Temporarily commented out while not using Secrets Manager
# output "db_secret_arn" {
#   description = "ARN of the Secrets Manager secret for the DB credentials."
#   value       = aws_secretsmanager_secret.db_creds.arn
# }

output "db_security_group_id" {
  description = "The ID of the security group for the database."
  value       = aws_security_group.db.id
}

output "db_host" {
  description = "The RDS instance endpoint."
  value       = aws_db_instance.main.address
}

output "db_password" {
  description = "The database password."
  value       = random_password.master.result
  sensitive   = true
}

output "db_name" {
  description = "The database name."
  value       = aws_db_instance.main.db_name
} 