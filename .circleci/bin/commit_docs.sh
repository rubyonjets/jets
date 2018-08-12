#!/bin/bash -eux

# Even though specs also generate docs, lets run again to ensure clean slate
rake docs

out=$(git status docs)
if [[ "$out" = *"nothing to commit"* ]]; then
  exit
fi

COMMIT_MESSAGE="docs updated by circleci"

# If the last commit already updated the docs, then exit.
# Preventable measure to avoid infinite loop.
if git log -1 --pretty=oneline | grep "$COMMIT_MESSAGE" ; then
  exit
fi

# If reach here, we have some changes on docs that we should commit.
# Even though s
git add docs
git commit -m "$COMMIT_MESSAGE"

# https://makandracards.com/makandra/12107-git-show-current-branch-name-only
current_branch=$(git rev-parse --abbrev-ref HEAD)
git push origin "$current_branch"
