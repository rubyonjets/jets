---
title: Installation
---

## RubyGems

Install jets via RubyGems.

    gem install jets

## Prerequisites and Dependencies

Jets works on macosx and linux variants. Jets does not work on windows.  For windows, recommend considering [Cloud9 IDE](https://aws.amazon.com/cloud9/). There are some nice advantages like [Faster Development](https://rubyonjets.com/docs/faster-development/).

### Ruby

Jets supports Ruby 2.5 and Ruby 2.7. Patch variants of it should work. More details: [Using Different Ruby Versions]({% link _docs/extras/ruby-versions.md %}).

### Yarn

For apps with HTML pages, jets uses [webpacker](https://github.com/rails/webpacker) to compile assets, which requires yarn.  [Node version manager](https://github.com/creationix/nvm), nvm, is recommended if you want to manage node versions.

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
    # note follow the instructions after the curl command to source nvm
    nvm install v12.13.0
    nvm alias default node # sets the default version

Once node is installed, install yarn with:

    npm install -g yarn

You can use any version of yarn that works with webpacker. If you run into webpacker issues, try upgrading node and yarn to the latest version. Also, upgrading the `yarn.lock` file with `yarn upgrade` sometimes helps.

## Database

By default, when you run a `jets new` command, Jets calls `bundle install` and attempts to install the `mysql2` gem. If you want to use PostgreSQL, run `jets new --database=postgresql`. Make sure that you have MySQL or PostgreSQL installed beforehand.

If you don't need an ORM database adapter, or want to use another database, use the `jets new --no-database` option. You can subsequently add any datastore adapter gem to the Gemfile, and run `bundle install`.

Here are the instructions to install MySQL and PostgreSQL:

### MySQL

    brew install mysql # macosx
    yum install -y mysql-devel # amazonlinux2 and redhat variants
    apt-get install -y libmysqlclient-dev # ubuntu and debian variants

### PostgreSQL

    brew install postgresql # macosx
    yum install -y postgresql-devel # amazonlinux2 and redhat variants
    apt-get install libpq-dev # ubuntu and debian variants

### AWS CLI

The AWS CLI is required. You can install the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) via pip.

    pip install awscli --upgrade --user

Then [configure it](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).

    aws configure

