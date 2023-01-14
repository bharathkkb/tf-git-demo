
# random suffix to prevent collisions
resource "random_id" "suffix" {
  byte_length = 4
}

module "logging-project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 12.0"

  name              = "fs-logging"
  random_project_id = true
  org_id            = var.org_id
  folder_id         = var.folder_id

  billing_account = var.billing_account
}


module "vpc-host-dev" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 12.0"

  name              = "fs-vpc-host-dev"
  random_project_id = true
  org_id            = var.org_id
  folder_id         = var.folder_id

  billing_account                = var.billing_account
  enable_shared_vpc_host_project = true
}
