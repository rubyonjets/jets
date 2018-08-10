---
title: Installation
---

## RubyGems

You can also install jets via RubyGems.

{% highlight sh %}
gem install jets
{% endhighlight %}

Or you can add jets to your Gemfile in your project if you are working with a ruby project.  It is not required for your project to be a ruby project to use jets.

{% highlight ruby %}
gem "jets"
{% endhighlight %}

## Dependencies

For apps with html pages, jets uses [webpacker](https://github.com/rails/webpacker) to compile assets requires node's yarn.  [Node version manager](https://github.com/creationix/nvm), nvm, is recommendeded to install a desired version of node. Once node is installed, install yarn with:

{% highlight sh %}
npm install -g yarn
{% endhighlight %}

You can use any version of yarn that works with webpacker.

## Bolts Toolbelt

If you want to install jets without having to worry about jets's ruby dependency you can install the Bolts Toolbelt which has jets included.

{% highlight sh %}
brew cask install boltopslabs/software/bolts
{% endhighlight %}

For more information about the Bolts Toolbelt or to get an installer for another operating system visit: [https://boltops.com/toolbelt](https://boltops.com/toolbelt)

<a id="prev" class="btn btn-basic" href="{% link _docs/workers.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/structure.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
