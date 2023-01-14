output "fs_repo_name" {
  value = github_repository.foundation.id
}

output "fs_repo_full_name" {
  value = github_repository.foundation.full_name
}

output "catalog_repo_name" {
  value = github_repository.catalog.id
}

output "catalog_repo_full_name" {
  value = github_repository.catalog.full_name
}

output "teams_repo_name" {
  value = github_repository.teams.id
}

output "teams_repo_full_name" {
  value = github_repository.teams.full_name
}

output "backend" {
  value = google_storage_bucket.backend.name
}

// common outputs for re use via remote state
output "org_id" {
  value = var.org_id
}

output "folder_id" {
  value = var.folder_id
}

output "billing_account" {
  value = var.billing_account
}

output "gh_org" {
  value = var.gh_org
}