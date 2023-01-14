module "dev-app" {
  source          = "../catalog-src/blueprints/run-app"
  project_id      = var.project_id
  app_name        = var.app_name
  image_url       = var.image_url
  host_project_id = var.host_project_id
  subnet_name     = var.subnet_name
}