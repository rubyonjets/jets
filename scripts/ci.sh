#!/bin/bash -exu

sudo apt-get install -y vim

cd
APP_NAME=demo$(date +%s)

# On circleci, initially jets is set up as /usr/local/bundle/bin/jets and
# has BUNDLE_GEMFILE set to /home/circleci/repo/Gemfile.
# Example capture: https://gist.github.com/tongueroo/1b41256d5867d14597f0cb5de67295b3
# This means that the jets command is the same as the project that circleci is
# testing.
# Using this jets to initially create the project
jets new $APP_NAME
# jets new calls the following for us automatically:
# bundle # this overwrites /usr/local/bundle/bin/jets
# jets webpacker:install
cd $APP_NAME

# Using the bundled jets now because is circleci has a bunch of BUNDLER_* env
# variables set up and this will make it use the right bundled gems.
bundle exec jets generate scaffold Post title:string
# The DB_ environment variables are set up in the circleci environment variables
# website GUI under project settings
bundle exec jets db:create db:migrate

# HERE
bundle exec jets deploy

APP_URL=$(bundle exec jets url)
curl -v ${API_URL}/posts # should have 200 status

# TODO: run capabara rack-test adapter
# 1. download spec/features/posts_spec.rb
# 2. bundle exec rspec
# This tests CR of CRUD.  UPDATE and DELETE are WIP because they use PUT and DELETE
# http methods.

# cleanup the database
bundle exec jets db:drop
