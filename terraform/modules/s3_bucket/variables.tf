variable "account_id" {
  type        = string
  description = "(Required) The account ID of the account the repo is deployed to"
}

variable "region" {
  type        = string
  description = "(Required) The region to deploy to"
}

variable "kms_key_arn" {
  type        = string
  description = "(Required) The ARN of the KMS key to use for encryptiong the bucket at rest"
}

variable "bucket_name" {
  type        = string
  description = "(Optional) name of the S3 bucket. A suffix of region-accountid is added to the end. If not provided, a random buckdet name is generaated"

  validation {
    condition     = length(var.bucket_name) < 36
    error_message = "The maximum provided length of the bucket name cannot exceed 35 characters"
  }

  default = null
}

variable "tags" {
  type        = map(any)
  description = "(Optional) Map of tags to add to all resources"

  default = {}
}

locals {
  bucket_name = "${var.bucket_name}-${var.region}-${var.account_id}"
}
