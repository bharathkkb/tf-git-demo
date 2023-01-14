terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.12"
    }
  }
}

provider "github" {
  owner = var.gh_org
}
