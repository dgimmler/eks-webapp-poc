variable "account_id" {
  type        = string
  description = "(Required) The account ID of the account the repo is deployed to"
}

variable "region" {
  type        = string
  description = "(Required) The region to deploy to"
}

variable "repo_name" {
  type        = string
  description = "(Required) name of the ECR repository"
}

variable "kms_key_arn" {
  type        = string
  description = "(Optional) ARN of the KMS key to use for encryption ECR repo"

  default = null
}

variable "tags" {
  type        = map(any)
  description = "(Optional) Map of tags to add to all resources"

  default = {}
}