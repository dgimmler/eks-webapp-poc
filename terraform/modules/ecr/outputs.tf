output "repo_uri" {
  description = "The URI of the created ECR repo"
  value       = aws_ecr_repository.main.repository_url
}

output "repo_name" {
  description = "The Name of the created ECR repo"
  value       = aws_ecr_repository.main.name
}

output "repo_login_cmd" {
  description = "Cmd to login to repo"
  value       = <<EOF
  aws ecr get-login-password \
    --region ${var.region} | docker login \
        --username AWS \
        --password-stdin ${aws_ecr_repository.main.repository_url}
EOF
}
