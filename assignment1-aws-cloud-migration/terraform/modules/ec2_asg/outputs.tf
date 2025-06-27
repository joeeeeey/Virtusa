output "app_security_group_id" {
  description = "The ID of the security group for the application."
  value       = aws_security_group.app.id
} 