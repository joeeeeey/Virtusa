output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret for the DB credentials."
  value       = aws_secretsmanager_secret.db_creds.arn
}

output "db_security_group_id" {
  description = "The ID of the security group for the database."
  value       = aws_security_group.db.id
} 