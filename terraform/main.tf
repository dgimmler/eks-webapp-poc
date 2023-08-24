module "kms" {
  providers = {
    aws = aws
  }

  source = "./modules/kms"

  account_id  = var.account_id
  description = "KMS key for project ${var.project_name}"
  key_alias   = "${var.project_name}-key"
  key_services = [
    "s3.amazonaws.com",
    "logs.amazonaws.com",
    "logs.${var.region}.amazonaws.com"
  ]

  tags = var.tags
}

module "ecr" {
  providers = {
    aws = aws
  }

  source = "./modules/ecr"

  account_id = var.account_id
  region     = var.region
  repo_name  = local.ecr_repo_name

  tags = var.tags
}


// NOTE: For the sake of simplicity, I am using the AWS provided VPC module as it
// conveniently sets up the route tables, NAT gateways and other supporting VPC
// resources for us. In a produciton environment, we would want to manage our
// own module.
module "vpc" {
  providers = {
    aws = aws
  }

  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.project_name
  cidr = var.vpc_cidr

  azs             = local.availability_zones
  private_subnets = [for k, v in local.availability_zones : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.availability_zones : cidrsubnet(var.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = var.tags
}

// NOTE: For the sake of simplicity, I am using the AWS provided EKS module as it
// conveniently sets up the security groups, IAM roles, KMS keys and other supporting
// resources for us. See note on VPC module above. We set up the nodes in a
// private subnet and will use an ALB in the public subnet to expose the application
// endpoint.
module "eks" {
  providers = {
    aws = aws
  }

  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.13"

  cluster_name                   = var.project_name
  cluster_version                = "1.27"
  cluster_endpoint_public_access = true // for production we would want this private

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    initial = {
      instance_types = var.eks_instance_types

      min_size     = var.eks_min_size
      max_size     = var.eks_max_size
      desired_size = var.eks_desired_size
    }
  }

  tags = var.tags
}

module "eks_service_account" {
  providers = {
    aws = aws
  }

  source = "./modules/eks_iam_service_account"

  account_id   = var.account_id
  project_name = var.project_name

  tags = var.tags
}

module "app_pipeline_artifacts_bucket" {
  providers = {
    aws = aws
  }

  source = "./modules/s3_bucket"

  account_id  = var.account_id
  region      = var.region
  bucket_name = "${var.project_name}-artifacts"
  kms_key_arn = module.kms.kms_key_arn

  tags = var.tags
}

module "app_pipeline" {
  providers = {
    aws = aws
  }

  source = "./modules/app-pipeline"

  account_id           = var.account_id
  region               = var.region
  pipeline_name        = var.project_name
  environment          = var.environment
  artifact_bucket_name = module.app_pipeline_artifacts_bucket.bucket_name
  kms_key_arn          = module.kms.kms_key_arn
  ecr_repo_uri         = module.ecr.repo_uri
  ecr_repo_name        = module.ecr.repo_name
  eks_cluster_name     = module.eks.cluster_name

  tags = var.tags
}
