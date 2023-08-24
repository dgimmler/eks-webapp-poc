variable "account_id" {
  type        = string
  description = "(Required) The account ID of the account the repo is deployed to"
}

variable "description" {
  type        = string
  description = "(Optional) A description to add to the KMS key"

  default = null
}

variable "key_admins" {
  type        = list(string)
  description = "(Optional) list of AWS principals who will have admin access to the Key. Defaults to allowing all authenticated users"

  default = null
}

variable "key_services" {
  type        = list(string)
  description = "(Optional) list of AWS serves that will have admin access to the Key. Defaults to allowing codebuild and codepipeline"

  default = null
}

variable "key_alias" {
  type        = string
  description = "(Optional) Optional human-readable KMS name"

  default = null
}

variable "tags" {
  type        = map(any)
  description = "(Optional) Map of tags to add to all resources"

  default = {}
}

locals {
  key_admins = jsonencode(
    var.key_admins != null ? var.key_admins : ["arn:aws:iam::${var.account_id}:root"]
  )
  required_key_services = ["codebuild.amazonaws.com", "codepipeline.amazonaws.com"]
  key_services = jsonencode(
    var.key_services == null ? local.required_key_services : distinct(compact(concat(
      var.key_services,
      local.required_key_services,
      [""]
    )))
  )
}
