# TF Git Demo

## Instructions

1) Install prereqs
1) Authenicate with gcloud `gcloud auth application-default login`
1) Ensure authenticated user has org admin, project creator roles (todo)
1) Assign values for TF vars in ./bootstrap-src via tfvars or envvars
1) Generate Github PAT token with repo create permissions and export as `GITHUB_TOKEN`
1) Confirm GH auth is setup with `gh auth status`
1) Run `./bootstrap.sh` for initial boostrapping. Apply and approve generated PRs
1) Run `./app.sh` for onboarding new apps

## Prereqs

- [gcloud](https://cloud.google.com/sdk/gcloud)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [go](https://go.dev/doc/install)
- [gum](https://github.com/charmbracelet/gum)
- [gh](https://cli.github.com/)
- [terraform](https://developer.hashicorp.com/terraform/downloads)
