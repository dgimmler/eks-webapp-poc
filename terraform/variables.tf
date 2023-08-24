variable "account_id" {
  type        = string
  description = "(Required) The Account ID of the account to deploy to"
}

variable "region" {
  type        = string
  description = "(Required) The region to deploy to"
}

variable "project_name" {
  type        = string
  description = "(Required) The project name"
}

variable "environment" {
  type        = string
  description = "(Required) The environment name (ex: dev)"
}

variable "ecr_repo_name" {
  type        = string
  description = "(Optional) name of the ECR repository"

  default = null
}

variable "vpc_cidr" {
  type        = string
  description = "(Optional) Vpc Cidr range. Default is 10.0.0.0/16"

  default = "10.0.0.0/16"
}

variable "eks_instance_types" {
  type        = list(string)
  description = "(Optional) List of EKS Ec2 instance types to support the EKS cluster as cluster nodes. Defaults to t2.micro"

  default = ["t2.micro"]
}

variable "eks_min_size" {
  type        = number
  description = "(Optional) Minimum number of required EC2 instance nodes for EKS cluster. Defaults to 0"

  default = 0
}

variable "eks_max_size" {
  type        = number
  description = "(Optional) Maximum number of required EC2 instance nodes for EKS cluster. Defaults to 5"

  default = 5
}

variable "eks_desired_size" {
  type        = number
  description = "(Optional) Desired number of required EC2 instance nodes for EKS cluster. Defaults to 2"

  default = 2
}

variable "tags" {
  type        = map(any)
  description = "(Optional) Map of tags to add to all resources"

  default = {}
}

locals {
  ecr_repo_name      = var.ecr_repo_name != null ? var.ecr_repo_name : var.project_name
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
}
