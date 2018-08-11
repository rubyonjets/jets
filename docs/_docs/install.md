---
title: Installation
---

## RubyGems

You can also install jets via RubyGems.

    gem install jets

Or you can add jets to your Gemfile in your project if you are working with a ruby project.  It is not required for your project to be a ruby project to use jets.

```ruby
gem "jets"
```

## Dependencies

For apps with HTML pages, jets uses [webpacker](https://github.com/rails/webpacker) to compile assets requires node's yarn.  [Node version manager](https://github.com/creationix/nvm), nvm, is recommended to install a desired version of node. Once node is installed, install yarn with:

    npm install -g yarn

You can use any version of yarn that works with webpacker.

<a id="prev" class="btn btn-basic" href="{% link _docs/workers.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/structure.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
