#!/bin/bash -eux

# git push:
#   CODEBUILD_WEBHOOK_HEAD_REF=refs/heads/codebuild
#   CODEBUILD_WEBHOOK_TRIGGER=branch/codebuild
#   CODEBUILD_SOURCE_VERSION=f0eb542 # resolved sha
# cb start:
#   CODEBUILD_SOURCE_VERSION=codebuild

git config --global user.email "tongueroo@gmail.com"
git config --global user.name "Tung Nguyen"

set +u # cb start will not have CODEBUILD_WEBHOOK_TRIGGER set
if [ -n "$CODEBUILD_WEBHOOK_TRIGGER" ]; then # git push
  BRANCH=$(echo $CODEBUILD_WEBHOOK_TRIGGER | sed "s/.*\///")
elif [ -n "$CODEBUILD_SOURCE_VERSION" ]; then # cb start
  BRANCH=$CODEBUILD_SOURCE_VERSION # contains the actual branch
else
  BRANCH=UNKNOWN-BRANCH
fi
git checkout $BRANCH
