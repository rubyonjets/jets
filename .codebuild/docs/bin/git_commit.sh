#!/bin/bash -eux

out=$(git status docs)
if [[ "$out" = *"nothing to commit"* ]]; then
  exit
fi

COMMIT_MESSAGE="docs updated by codebuild"

# If the last commit already updated the docs, then exit.
# Preventable measure to avoid infinite loop.
if git log -1 --pretty=oneline | grep "$COMMIT_MESSAGE" ; then
  exit
fi

# If reach here, we have some changes on docs that we should commit.
git add docs
git commit -m "$COMMIT_MESSAGE"

# SSH_KEY_S3_PATH set as codebuild environment variable
aws s3 cp $SSH_KEY_S3_PATH ~/.ssh/id_rsa
chmod 400 ~/.ssh/id_rsa
sed -i -- 's|https://github.com/|git@github.com:|g' .git/config

# https://makandracards.com/makandra/12107-git-show-current-branch-name-only
current_branch=$(git rev-parse --abbrev-ref HEAD)
git push origin "$current_branch"
