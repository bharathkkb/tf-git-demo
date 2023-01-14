terraform {
  backend "gcs" {
    prefix = "terraform/teams"
  }
}