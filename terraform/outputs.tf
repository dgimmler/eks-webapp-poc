output "ecr_login_cmd" {
  description = "The login command for the ECR repo"
  value       = module.ecr.repo_login_cmd
}

output "ecr_uri" {
  description = "The repo URI of the ECR repo"
  value       = module.ecr.repo_uri
}

output "kubectl_login_cmd" {
  description = "The login command for the created EKS cluster"
  value       = <<EOF
  aws eks update-kubeconfig \
    --name ${module.eks.cluster_name} \
    --region ${var.region} 
EOF
}

output "service_account_role_arn" {
  description = "The ARN of the created servcie ccount role"
  value       = module.eks_service_account.role_arn
}

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}
