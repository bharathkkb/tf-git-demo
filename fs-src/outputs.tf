# output "backend" {
#   value = google_storage_bucket.backend.name
# }

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

output "host_project_id" {
  value = module.vpc-host-dev.project_id
}

output "network_self_link" {
  value = module.dev-base.network_id
}

output "subnets_names" {
  value = module.dev-base.subnets_names
}