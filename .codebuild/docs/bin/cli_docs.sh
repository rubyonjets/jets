#!/bin/bash -eux

# Generate docs
gem install bundler:1.16.6
bundle
rake docs
