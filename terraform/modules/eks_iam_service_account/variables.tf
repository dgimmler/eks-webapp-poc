variable "account_id" {
  type        = string
  description = "(Required) The account ID of the account the repo is deployed to"
}

variable "project_name" {
  type        = string
  description = "(Required) The project name"
}

variable "tags" {
  type        = map(any)
  description = "(Optional) Map of tags to add to all resources"

  default = {}
}
