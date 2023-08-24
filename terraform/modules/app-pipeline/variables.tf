variable "account_id" {
  type        = string
  description = "(Required) The account ID of the account the repo is deployed to"
}

variable "region" {
  type        = string
  description = "(Required) The region to deploy to"
}

variable "pipeline_name" {
  type        = string
  description = "(Required) name of the pipeline"

  validation {
    condition     = length(var.pipeline_name) < 26
    error_message = "The maximum provided length of the pipeline name cannot exceed 25 characters"
  }
}

variable "environment" {
  type        = string
  description = "(Required) The environment name (ex: dev)"
}

variable "artifact_bucket_name" {
  type        = string
  description = "(Required) The name of the S3 bucket to use for storing all pipeline artifacts"
}

variable "kms_key_arn" {
  type        = string
  description = "(Required) The ARN of the KMS to use for encrypting all pipeline logs and artifacts"
}

variable "ecr_repo_uri" {
  type        = string
  description = "(Required) The URI of the ECR repo to push images to"
}

variable "ecr_repo_name" {
  type        = string
  description = "(Required) The name of the ECR repo to push images to"
}

variable "eks_cluster_name" {
  type        = string
  description = "(Required) The name of the EKS cluster to deploy to"
}

variable "runner_instance_type" {
  type        = string
  description = "(Optional) The instance type for the build project runners. Defaults to BUILD_GENERAL1_SMALL."

  validation {
    condition = contains([
      "BUILD_GENERAL1_SMALL",
      "BUILD_GENERAL1_MEDIUM",
      "BUILD_GENERAL1_LARGE",
      "BUILD_GENERAL1_2XLARGE"
    ], var.runner_instance_type)
    error_message = "Invalid instance type. Must be one of BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, BUILD_GENERAL1_LARGE or BUILD_GENERAL1_2XLARGE"
  }

  default = "BUILD_GENERAL1_SMALL"
}

variable "tags" {
  type        = map(any)
  description = "(Optional) Map of tags to add to all resources"

  default = {}
}

locals {
  unittest_project_name = "${var.pipeline_name}-unittest"
  build_project_name    = "${var.pipeline_name}-build"
  ecr_scan_project_name = "${var.pipeline_name}-ecr-scan"
  deploy_project_name   = "${var.pipeline_name}-deploy"
}
