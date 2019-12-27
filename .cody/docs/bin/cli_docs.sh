#!/bin/bash -eux

# Unsure why but setting BUNDLE_GEMFILE fixes build in the codebuild docker env
export BUNDLE_GEMFILE=$(pwd)/Gemfile
bundle
rake docs
