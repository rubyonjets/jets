#!/bin/bash -eux

# This Docker image needs bundler 1.16.6 installed
gem install bundler:1.16.6
echo $BUNDLER_VERSION

# Generate docs
gem update --system
