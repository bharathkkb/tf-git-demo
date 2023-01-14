set -e

# gum colors
export GUM_INPUT_CURSOR_FOREGROUND="#FF0"
export GUM_INPUT_PROMPT_FOREGROUND="#0FF"
export FOREGROUND="#4AF626"

if [[ -z "${GITHUB_TOKEN}" ]]; then
  echo "Please set GITHUB_TOKEN"
  exit 1
fi

SUFFIX=$(gum input --prompt "Suffix for resources: " --value="-baz-corp")
GH_ORG_INPUT=$(gum input --prompt "Github org to use: " --value="bharathkkb-test-org-1")

export TF_VAR_suffix=${SUFFIX}
export TF_VAR_gh_token=${GITHUB_TOKEN}
export TF_VAR_gh_org=${GH_ORG_INPUT}

gum style "Creating foundation repo, teams repo, catalog repo and CI/CD."
terraform -chdir=bootstrap-src init
terraform -chdir=bootstrap-src plan -out plan.out
gum confirm "Apply?" && terraform -chdir=bootstrap-src apply plan.out

# Foundation repo
FS_REPO_FULL=$(terraform -chdir=bootstrap-src output -raw fs_repo_full_name)
FS_REPO_NAME=$(terraform -chdir=bootstrap-src output -raw fs_repo_name)

gum style "Bootstrapping foundation repo."

# todo: pull these into a function
mkdir -p temp
cd temp
if [ -d "${FS_REPO_NAME}" ]; then
  echo "Removing ${FS_REPO_NAME} to reclone"
  rm -rf ${FS_REPO_NAME}
fi

gh repo clone "${FS_REPO_FULL}"
cd ${FS_REPO_NAME}

RAND=$(echo $RANDOM | base64 | head -c 20;)
BRANCH_NAME="tmp-${RAND}"
git config user.name platform-admin --local
git config user.email platform-admin@foo.com --local
git checkout -b ${BRANCH_NAME}
cp -r ../../fs-src/ .
if [ -z $(git status --porcelain) ];
then
    echo "Skipping PR; nothing to commit in ${FS_REPO_NAME}"
else
    git add -A
    git commit -m "add foundation"
    git push --set-upstream origin ${BRANCH_NAME}
    gh pr create --title "add foundation" --body "add foundation TF configs\\nAuthor: Foundation bot \\n Reviewer: Charlie"
fi
cd ../..

# Catalog repo
gum style "Bootstrapping catalog repo."

CATALOG_REPO_FULL=$(terraform -chdir=bootstrap-src output -raw catalog_repo_full_name)
CATALOG_REPO_NAME=$(terraform -chdir=bootstrap-src output -raw catalog_repo_name)

cd temp
if [ -d "${CATALOG_REPO_NAME}" ]; then
  echo "Removing ${CATALOG_REPO_NAME} to reclone"
  rm -rf ${CATALOG_REPO_NAME}
fi

gh repo clone "${CATALOG_REPO_FULL}"
cd ${CATALOG_REPO_NAME}

RAND=$(echo $RANDOM | base64 | head -c 20;)
BRANCH_NAME="tmp-${RAND}"
git config user.name platform-developer --local
git config user.email platform-developer@foo.com --local
git checkout -b ${BRANCH_NAME}
cp -r ../../catalog-src/ .

if [ -z $(git status --porcelain) ];
then
    echo "Skipping PR; nothing to commit in ${CATALOG_REPO_NAME}"
else
  git add -A
  git commit -m "populate org catalog"
  git push --set-upstream origin ${BRANCH_NAME}
  gh pr create --title "populate org catalog" --body "populate org catalog\\nAuthor: Ida \\n Reviewer: Platform dev team"
fi
cd ../..

# Teams repo
gum style "Bootstrapping teams repo."

TEAMS_REPO_FULL=$(terraform -chdir=bootstrap-src output -raw teams_repo_full_name)
TEAMS_REPO_NAME=$(terraform -chdir=bootstrap-src output -raw teams_repo_name)

cd temp
if [ -d "${TEAMS_REPO_NAME}" ]; then
  echo "Removing ${TEAMS_REPO_NAME} to reclone"
  rm -rf ${TEAMS_REPO_NAME}
fi

gh repo clone "${TEAMS_REPO_FULL}"
cd ${TEAMS_REPO_NAME}

RAND=$(echo $RANDOM | base64 | head -c 20;)
BRANCH_NAME="tmp-${RAND}"
git config user.name platform-developer --local
git config user.email platform-developer@foo.com --local
git checkout -b ${BRANCH_NAME}
cp -r ../../teams-src/ .

if [ -z $(git status --porcelain) ];
then
    echo "Skipping PR; nothing to commit in ${TEAMS_REPO_NAME}"
else
  git add -A
  git commit -m "init teams"
  git push --set-upstream origin ${BRANCH_NAME}
  gh pr create --title "initialize teams" --body "initialize teams\\nAuthor: Ida \\n Reviewer: Platform dev team"
fi
cd ../..

gum style "Bootstrap complete!"