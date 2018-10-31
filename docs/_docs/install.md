---
title: Installation
---

## RubyGems

You can install jets via RubyGems.

    gem install jets

Or you can add jets to your Gemfile in your project.

```ruby
gem "jets"
```

## Prerequisites

### AWS CLI

You can install the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) via pip.

    pip install awscli --upgrade --user

Then [configure it](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).

    aws configure

## Dependencies

### Ruby

Jets uses Ruby 2.5.0 and code written with patch variants of it will work.

### Yarn

For apps with HTML pages, jets uses [webpacker](https://github.com/rails/webpacker) to compile assets which requires node's yarn.  [Node version manager](https://github.com/creationix/nvm), nvm, is recommended to install a desired version of node.  Here's a node install cheatsheet, though prelease refer to the links for the most updated commands with possible more recent versions:

    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
    # note follow the instructions after the curl command to source nvm
    nvm install 8.10.0 # please check AWS Lambda for the latest node runtime
    nvm alias default node # sets the default version

Once node is installed, install yarn with:

    npm install -g yarn

You can use any version of yarn that works with webpacker.

## Database

By default, when you run a `jets new` command, it generates a Gemfile that has database adapter gem like `pg` or `mysql2`. A `bundle install` is run immediately as part of the `jets new` command. So the specific database needs to be installed.  The current default ORM database is MySQL.

If you do not need an ORM database adapter, you can use the `jets new --no-database` option, and a database gem will not be added to the Gemfile.

Here are various ways to install different databases:

### PostgreSQL

    brew install postgresql # macosx
    yum install -y postgresql-devel # amazonlinux2 and redhat variants
    apt-get install libpq-dev # ubuntu and debian variants

### MySQL

    brew install mysql # macosx
    yum install -y mysql-devel # amazonlinux2 and redhat variants
    apt-get install -y libmysqlclient-dev # ubuntu and debian variants

<a id="prev" class="btn btn-basic" href="{% link _docs/jobs.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/structure.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
