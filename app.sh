set -e

# gum colors
export GUM_INPUT_CURSOR_FOREGROUND="#FF0"
export GUM_INPUT_PROMPT_FOREGROUND="#0FF"
export FOREGROUND="#4AF626"
export GUM_INPUT_WIDTH=80

if [[ -z "${GITHUB_TOKEN}" ]]; then
  echo "Please set GITHUB_TOKEN"
  exit 1
fi


APP_NAME=$(gum input --prompt "App name: " --value="hello-app")
CATALOG_REPO_FULL=$(terraform -chdir=bootstrap-src output -raw catalog_repo_full_name)
GH_ORG=$(terraform -chdir=bootstrap-src output -raw gh_org)
SAMPLE_APP_TF=$(sed -e "s|REPLACE_ME|${CATALOG_REPO_FULL}|g; s|APP_NAME|${APP_NAME}|g" sample-app.tf.tmpl)
gum style "Generated ${APP_NAME} onboarding config to create common resources like CI/CD and app project."
APP_TF=$(gum write --value="${SAMPLE_APP_TF}" --show-cursor-line)


# Add app to teams repo
TEAMS_REPO_FULL=$(terraform -chdir=bootstrap-src output -raw teams_repo_full_name)
TEAMS_REPO_NAME=$(terraform -chdir=bootstrap-src output -raw teams_repo_name)
mkdir -p temp
cd temp
if [ -d "${TEAMS_REPO_NAME}" ]; then
  echo "Removing ${TEAMS_REPO_NAME} to reclone"
  rm -rf ${TEAMS_REPO_NAME}
fi

gh repo clone "${TEAMS_REPO_FULL}"
cd ${TEAMS_REPO_NAME}

RAND=$(echo $RANDOM | base64 | head -c 20;)
BRANCH_NAME="tmp-${RAND}"
git config user.name app-operator --local
git config user.email app-operator@foo.com --local
git checkout -b ${BRANCH_NAME}
echo "$APP_TF" > ${APP_NAME}.tf

if [ -z $(git status --porcelain) ];
then
    echo "Skipping PR; nothing to commit in ${TEAMS_REPO_NAME}"
else
  git add -A
  git commit -m "init ${APP_NAME} team"
  git push --set-upstream origin ${BRANCH_NAME}
  gh pr create --title "initialize ${APP_NAME} team" --body "initialize ${APP_NAME} team\\nAuthor: Alice \\n Reviewer: Ida"
fi
cd ../..

gum confirm "Previous PR approved and deployed?"

# App source
APP_SOURCE_REPO_NAME="${APP_NAME}-source"
cd temp
if [ -d "${APP_SOURCE_REPO_NAME}" ]; then
  echo "Removing ${APP_SOURCE_REPO_NAME} to reclone"
  rm -rf ${APP_SOURCE_REPO_NAME}
fi
gh repo clone "${GH_ORG}/${APP_SOURCE_REPO_NAME}"
cd ${APP_SOURCE_REPO_NAME}

RAND=$(echo $RANDOM | base64 | head -c 20;)
BRANCH_NAME="tmp-${RAND}"
git config user.name app-developer --local
git config user.email app-developer@foo.com --local
git checkout -b ${BRANCH_NAME}
cp -r ../../app-source-src/ .
if [ -z $(git status --porcelain) ];
then
    echo "Skipping PR; nothing to commit in ${APP_SOURCE_REPO_NAME}"
else
  git add -A
  git commit -m "init ${APP_NAME} source repo"
  git push --set-upstream origin ${BRANCH_NAME}
  gh pr create --title "initialize ${APP_NAME} source code" --body "initialize ${APP_NAME} source code\\nAuthor: Bob \\n Reviewer: App dev team"
fi
cd ../..


# App infra
APP_INFRA_REPO_NAME="${APP_NAME}-infra"
cd temp
if [ -d "${APP_INFRA_REPO_NAME}" ]; then
  echo "Removing ${APP_INFRA_REPO_NAME} to reclone"
  rm -rf ${APP_INFRA_REPO_NAME}
fi
gh repo clone "${GH_ORG}/${APP_INFRA_REPO_NAME}"
cd ${APP_INFRA_REPO_NAME}

RAND=$(echo $RANDOM | base64 | head -c 20;)
BRANCH_NAME="tmp-${RAND}"
git config user.name app-operator --local
git config user.email app-operator@foo.com --local
git checkout -b ${BRANCH_NAME}
cp -r ../../app-infra-src/ .
SAMPLE_TF=$(sed -e "s|REPLACE_ME|${CATALOG_REPO_FULL}|g; s|APP_NAME|${APP_NAME}|g" main.tf)
echo "${SAMPLE_TF}" > main.tf
if [ -z $(git status --porcelain) ];
then
    echo "Skipping PR; nothing to commit in ${APP_INFRA_REPO_NAME}"
else
  git add -A
  git commit -m "init ${APP_NAME} infra"
  git push --set-upstream origin ${BRANCH_NAME}
  gh pr create --title "initialize ${APP_NAME} infra" --body "initialize ${APP_NAME} infra"
fi
cd ../..

gum style "${APP_NAME} scaffolding complete!"