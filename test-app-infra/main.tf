module "test" {
  source           = "../catalog-src/blueprints/app-infra"
  app_name         = "foo"
  org_remote_state = "gh-bootstrap-46c3-tf-org-backend"
}