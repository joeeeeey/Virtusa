output "alb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.main.dns_name
}

output "alb_security_group_id" {
  description = "The ID of the security group for the load balancer."
  value       = aws_security_group.alb.id
}

output "target_group_arn" {
  description = "The ARN of the target group."
  value       = aws_lb_target_group.main.arn
}

output "listener_arn" {
  description = "The ARN of the listener."
  value       = aws_lb_listener.http.arn
} 