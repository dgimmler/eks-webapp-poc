terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.47"
    }
  }

  # backend "s3" {
  #   bucket = "terraform-state"
  #   region = "us-west-2"
  #   key    = "eks-webapp-poc/demo/terraform.tfstate"
  # }
}

provider "aws" {
  region = var.region
}
