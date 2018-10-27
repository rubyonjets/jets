---
title: Rails Support
---

Jets supports Rails and allows you to run it on AWS Lambda without little or no work.  You simply run an import command, test, and deploy.

## Example

Mega Mode can be set up with the `jets import` command.  Here's an example of importing a Rails application and setting it up with Mega Mode.

    cd demo # demo is jets app
    jets import:rails http://github.com/tongueroo/jets-examples-rails.git

This essentially copies the project to a rack folder within the demo jets app. The import command also adds an example route to `config/routes.rb` to enable mega mode.  It looks something like this:

```ruby
Jets.application.routes.draw do
  # ...
  # any "*catchall", to: "jets/public#show" # commented out by jets import
  # enables Mega Mode integration
  any "*catchall", to: "jets/rack#process"
end
```

The added catchall route maps to a special `jets/rack_controller` which forwards requests from the main jets app to the sub rails app in the `rack` folder.  This allows you to selectively route urls to the rails or the jets app, depending on your needs.

## Testing Rack App Locally

The `jets server` command automatically starts the sub-rack application server up for you.  Example:

    jets server # starts both jets and rack servers up

The jets server runs on port 8888 and the rack server runs on port 9292.

If you would like to test the rack application without jets directly you can always start up the rack app directly.

    cd demo/rack # go into the rack project folder directly
    bundle # install dependencies
    rackup # start up the rack app directly

Starting up the rack app directly is a good way to test it independently.

## Deploy

When you're ready to deploy, run:

    jets deploy

## Additional Import Examples

The import command understands a variety of values. Examples:

    jets import:rails tongueroo/jets-examples-rails # expands to github
    jets import:rails git@github.com:tongueroo/jets-examples-rails.git
    jets import:rails /path/to/folder/jets-examples-rails

<a id="prev" class="btn btn-basic" href="{% link _docs/megamode.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/megamode-considerations.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
