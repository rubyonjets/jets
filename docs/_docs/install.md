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

## Dependencies

### Ruby

Jets uses Ruby 2.5.0 and code written with patch variants of it will work.

### Yarn

For apps with HTML pages, jets uses [webpacker](https://github.com/rails/webpacker) to compile assets which requires node's yarn.  [Node version manager](https://github.com/creationix/nvm), nvm, is recommended to install a desired version of node. Once node is installed, install yarn with:

    npm install -g yarn

You can use any version of yarn that works with webpacker.

### PostgreSQL

The currently supported and default ORM database is PostgreSQL. When you run `jets new` command, it generates a Gemfile that has the `pg` gem. A `bundle install` is run as part of the `jets new` command. So you need PostgreSQL installed as a dependency.  Here are various ways to install it.

    brew install postgresql # macosx
    yum install -y postgresql-devel # amazonlinux2 and redhat variants
    apt-get install libpq-dev # ubuntu and debian variants

If you do not need an ORM database adapter, you can use the `--no-database` option and `jets new` will not insert the `pg` gem to the Gemfile.

<a id="prev" class="btn btn-basic" href="{% link _docs/jobs.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/structure.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
