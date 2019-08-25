#!/bin/bash -eux

# git push:
#   CODEBUILD_WEBHOOK_HEAD_REF=refs/heads/codebuild
#   CODEBUILD_WEBHOOK_TRIGGER=branch/codebuild
#   CODEBUILD_SOURCE_VERSION=f0eb542 # resolved sha
# cb start:
#   CODEBUILD_SOURCE_VERSION=codebuild

set +u
if [ -n "$CODEBUILD_WEBHOOK_TRIGGER" ]; then # git push
  BRANCH=$(echo $CODEBUILD_WEBHOOK_TRIGGER | sed "s/.*\///")
elif [ -n "$CODEBUILD_SOURCE_VERSION" ]; then # cb start
  BRANCH=$CODEBUILD_SOURCE_VERSION # contains the actual branch
else
  BRANCH=UNKNOWN-BRANCH
  exit 1
fi
set -u
git checkout $BRANCH

# Generate docs
# Even though specs also generate docs, lets run again to ensure clean slate
bundle
rake docs
