output "role_arn" {
  description = "The ARN of the created servcie ccount role"
  value       = aws_iam_role.eks_lb_controller_role.arn
}
