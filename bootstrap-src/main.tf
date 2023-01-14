# project to store GCS backends, WIF infra etc
module "bootstrap" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 12.0"

  name              = "gh-bootstrap"
  random_project_id = true
  org_id            = var.org_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account
  activate_apis = [
    "compute.googleapis.com",
    "admin.googleapis.com",
    "iam.googleapis.com",
    "billingbudgets.googleapis.com",
    "cloudbilling.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iamcredentials.googleapis.com", # WIF
  ]
}
