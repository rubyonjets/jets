#!/bin/bash -eux

# Generate docs
gem update --system
# Unsure why but setting BUNDLE_GEMFILE fixes build in the codebuild docker env
export BUNDLE_GEMFILE=$(pwd)/Gemfile
bundle
rake docs
