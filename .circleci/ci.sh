#!/bin/bash -exu

# Interesting, circleci has a custom /usr/local/bundle/bin files that changes
# how executables work. Example capture:
# https://gist.github.com/tongueroo/1b41256d5867d14597f0cb5de67295b3
# What results with the wrapper scripts:
#
#   * jets point to ~/repo/bin/jets
#   * bundle uses /home/circleci/repo/Gemfile
#
# This is quite confusing when because running bundle and jets commands after ssh
# into the box as it forces the use of /home/circleci/repo/Gemfile.
# Additionally, when new gems are installed some of the
# /usr/local/bundle/bin files gets overwritten, resulting in a mix bag of
# bin wrapper files. Seems like able to reset this behavior and make my life sane by:
#
#   1. unset all the BUNDLER_VERSION related variables
#   2. re-installing bundler
#   3. use own jets wrapper script
#

function create_jets_bin() {
  mkdir -p ~/bin
  cat >~/bin/jets <<EOL
#!/bin/bash
>&2 echo "Using local version at ~/repo/exe/jets"
unset BUNDLER_VERSION
unset BUNDLE_PATH
unset BUNDLE_APP_CONFIG
unset BUNDLE_SILENCE_ROOT_WARNING
unset BUNDLE_BIN
exec ~/repo/exe/jets "\$@"
EOL
  chmod a+x ~/bin/jets
}

cd

sudo apt-get install -y vim

#unset GEM_HOME # dont want to unset in the script but when Im ssh in, need to unset this and re-bundle...

create_jets_bin
export PATH=~/bin:$PATH
echo "export PATH=~/bin:$PATH" >> ~/.bashrc

# On circleci, initially jets is set up as /usr/local/bundle/bin/jets and
# has BUNDLE_GEMFILE set to /home/circleci/repo/Gemfile.
#
# This means that the jets command is the same as the project that circleci is
# testing.
# Using this jets to initially create the project
APP_NAME=demo$(date +%s)
cd ~/repo
gem install bundler
bundle
cd
jets new $APP_NAME # jets new runs bundle and webpacker:install
cd $APP_NAME

jets generate scaffold Post title:string
# The DB_ environment variables are set up in the circleci environment variables
# website GUI under project settings
jets db:create db:migrate

# HERE
jets deploy

APP_URL=$(jets url)
# curl doesnt return error status for 500 errors so will grep for 200
# to force a return status of false if it fails
curl -v ${APP_URL}/posts 2>&1 | grep '< HTTP' | grep 200 # should have 200 status

# TODO: run capabara rack-test adapter
# 1. download spec/features/posts_spec.rb
# 2. rspec
# This tests CR of CRUD.  UPDATE and DELETE are WIP because they use PUT and DELETE
# http methods.

# cleanup the database
jets db:drop

# delete jets project
jets delete --force
