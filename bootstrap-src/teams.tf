# Teams repo
resource "github_repository" "teams" {
  name                        = "teams${var.suffix}"
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
resource "google_service_account" "teams" {
  project    = module.bootstrap.project_id
  account_id = "teams-sa"
}

resource "google_project_iam_member" "teams" {
  project = module.bootstrap.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.teams.email}"
}

resource "google_billing_account_iam_member" "teams-billing" {
  billing_account_id = var.billing_account
  role               = "roles/billing.user"
  member             = "serviceAccount:${google_service_account.teams.email}"
}


resource "google_folder_iam_member" "teams" {
  for_each = toset([
    "roles/resourcemanager.organizationAdmin",
    "roles/resourcemanager.folderAdmin",
    "roles/resourcemanager.projectCreator",
    "roles/compute.xpnAdmin",
  ])
  folder = var.folder_id
  role   = each.key
  member = "serviceAccount:${google_service_account.teams.email}"
}

# WIF setup for github actions
module "gh_oidc_teams" {
  source      = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  project_id  = module.bootstrap.project_id
  pool_id     = "team-pool"
  provider_id = "team-gh-provider"
  sa_mapping = {
    (google_service_account.teams.account_id) = {
      sa_name   = google_service_account.teams.name
      attribute = "attribute.repository/${var.gh_org}/${github_repository.teams.id}"
    }
  }
}

resource "github_actions_secret" "teams-secrets" {
  for_each = {
    "PROJECT_ID" : module.bootstrap.project_id,
    "SERVICE_ACCOUNT_EMAIL" : google_service_account.teams.email,
    "WIF_PROVIDER_NAME" : module.gh_oidc_teams.provider_name,
    "ORG_BACKEND" : google_storage_bucket.backend.name,
    "TF_BACKEND" : google_storage_bucket.teams-backend.name,
    "ORG_ID" : var.org_id,
    "FOLDER_ID" : var.folder_id,
    "BILLING_ACCOUNT" : var.billing_account,
    "GH_TOKEN" : var.gh_token,
  }

  repository      = github_repository.teams.id
  secret_name     = each.key
  plaintext_value = each.value
}

# TF backend for teams configs
resource "google_storage_bucket" "teams-backend" {
  name                     = "${module.bootstrap.project_id}-tf-teams-backend"
  project                  = module.bootstrap.project_id
  location                 = "US"
  force_destroy            = true
  public_access_prevention = "enforced"
}
