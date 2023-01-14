variable "billing_account" {
  description = "The ID of the billing account to associate projects with"
  type        = string
}

variable "org_id" {
  description = "The organization id for the associated resources"
  type        = string
}

variable "folder_id" {
  description = "The folder id for the associated resources"
  type        = string
}

variable "gh_org" {
  description = "GH org to create bootstrap repo"
  type        = string
}

variable "gh_token" {
  description = "GH token used to bootstrap new repos"
  type        = string
}

# variable "gh_repo_name" {
#   description = "GH repo name for bootstrap repo"
#   type        = string
# }

variable "suffix" {
  type = string
}