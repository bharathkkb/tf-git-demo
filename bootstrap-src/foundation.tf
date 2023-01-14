# Foundation repo
resource "github_repository" "foundation" {
  name                        = "foundation${var.suffix}"
  allow_merge_commit          = false
  allow_rebase_merge          = false
  allow_update_branch         = true
  delete_branch_on_merge      = true
  has_issues                  = true
  has_projects                = false
  has_wiki                    = false
  vulnerability_alerts        = true
  has_downloads               = false
  squash_merge_commit_message = "BLANK"
  squash_merge_commit_title   = "PR_TITLE"
  auto_init                   = true
}

# SA to used in foundation repo cicd
resource "google_service_account" "sa" {
  project    = module.bootstrap.project_id
  account_id = "org-sa"
}

resource "google_project_iam_member" "project" {
  project = module.bootstrap.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_folder_iam_member" "folder_parent_iam" {
  for_each = toset([
    "roles/resourcemanager.organizationAdmin",
    "roles/resourcemanager.folderAdmin",
    "roles/resourcemanager.projectCreator",
    "roles/compute.xpnAdmin",
  ])
  folder = var.folder_id
  role   = each.key
  member = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_billing_account_iam_member" "editor" {
  billing_account_id = var.billing_account
  role               = "roles/billing.user"
  member             = "serviceAccount:${google_service_account.sa.email}"
}

# WIF setup for github actions
module "gh_oidc" {
  source      = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  project_id  = module.bootstrap.project_id
  pool_id     = "org-pool"
  provider_id = "org-gh-provider"
  sa_mapping = {
    (google_service_account.sa.account_id) = {
      sa_name   = google_service_account.sa.name
      attribute = "attribute.repository/${var.gh_org}/${github_repository.foundation.id}"
    }
  }
}

resource "github_actions_secret" "secrets" {
  for_each = {
    "PROJECT_ID" : module.bootstrap.project_id,
    "SERVICE_ACCOUNT_EMAIL" : google_service_account.sa.email,
    "WIF_PROVIDER_NAME" : module.gh_oidc.provider_name,
    "TF_BACKEND" : google_storage_bucket.backend.name,
    "ORG_ID" : var.org_id,
    "FOLDER_ID" : var.folder_id,
    "BILLING_ACCOUNT" : var.billing_account,
    "GH_ORG" : var.gh_org,
  }

  repository      = github_repository.foundation.id
  secret_name     = each.key
  plaintext_value = each.value
  depends_on = [
    github_repository.foundation
  ]
}

# TF backend for foundation configs
resource "google_storage_bucket" "backend" {
  name                     = "${module.bootstrap.project_id}-tf-org-backend"
  project                  = module.bootstrap.project_id
  location                 = "US"
  force_destroy            = true
  public_access_prevention = "enforced"
}
