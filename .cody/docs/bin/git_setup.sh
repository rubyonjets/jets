#!/bin/bash -eux

# git push:
#   CODEBUILD_WEBHOOK_HEAD_REF=refs/heads/codebuild
#   CODEBUILD_WEBHOOK_TRIGGER=branch/codebuild
#   CODEBUILD_SOURCE_VERSION=f0eb542 # resolved sha
# cb start:
#   CODEBUILD_SOURCE_VERSION=codebuild

git config --global user.email "tongueroo@gmail.com"
git config --global user.name "Tung Nguyen"

