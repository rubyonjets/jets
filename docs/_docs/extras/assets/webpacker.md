---
title: "Assets Serving: Webpack"
---

## Pros and Cons

There several benefits to using webpack to build assets like images.

* Webpacker adds sha checksums to assets as a part of building them to the `public/packs` folder.  The checksums optimize performance since images can be cached for very long periods of time. IE: 10y.
* You'll be able to configure high values for the `max-age` response header. This article [Increasing Application Performance with HTTP Cache Headers](https://devcenter.heroku.com/articles/increasing-application-performance-with-http-cache-headers) covers how cache headers work.  The default max-age for assets serving out of s3 is 3600s or 1h.
* If you replace an image and keep the same name, you don't have to update the code as the `image_pack_tag` uses the compiled image with the sha checksum. It's nice to offload menial tasks like file renames to automation. Instead, we can spend the precious mental energy on coding business logic.

There are also some downsides with using webpacker, though:

* Webpacker and the node world tend to move very rapidly. As such, it tends to feel like the wild west at times.
* This is the nature of the beast. Moving fast can break things. Configurations like `babel.config.js`, `.browserslistrc`, `config/webpacker/environment.js`, `postcss.config.js`, `config/webpacker.yml` interfaces can change. Here are just some examples: [2059](https://github.com/rails/webpacker/issues/2059), [2202](https://github.com/rails/webpacker/issues/2202), [2342](https://github.com/rails/webpacker/issues/2342)
* If you're not keeping up with the changes of the ecosystem, it is sometimes faster to treat things like black box. IE: Upgrade yarn, node, and regenerate the configuration files and see if that fixes issues.

All that being said, it is recommended that you take advantage of webpack for the benefits.

## How To Tutorial

Here's a summary of the steps on how to use webpacker for assets like images. Note, the folder structure and instructions can be adjusted your our own preferences.  The source code for this tutorial is available at: [tongueroo/jets-webpacker-demo](https://github.com/tongueroo/jets-webpacker-demo)

1. Put files in `app/assets/images`
2. Adjust `config/webpacker.yml` with the `resolved_paths` and `extract_css` settings.
3. Import images in `app/javascript/packs/application.js`. This is important as it's how webpacker and the javascript world know about the assets.
4. Use the `image_pack_tag` in your views with the conventional `media` prefix.

### 1. Put files in `app/assets/images`

We'll put files in:

    app/assets/
    └── images
        ├── jets.png
        └── southpark
            ├── eric.png
            └── stan.png

### 2. Adjust `config/webpacker.yml` with the `resolved_paths` and `extract_css` settings.

With webpacker, have found success by configuring `config/webpacker.yml` with:

config/webpacker.yml:

```yaml
default: &default
  # ...
  resolved_paths: ['app/assets']
  extract_css: true
```

Note, these should be the default values, but there are noted here in case these defaults change. Please double check `config/webpacker.yml`.

### 3. Import images in `app/javascript/packs/application.js`

This is an important step as the javascript world and webpacker will not know to compile your assets and images unless they are imported. Running `bin/webpack` evaluates the javascript code and each import call adds info to be tracked. This is how webpack knows to compile the images and add them to `public/packs/manifest.json`.  Note: In development mode, `bin/webpack` runs automatically as part of the request cycle.

Instead of importing images one at a time, we'll import the entire folder recursively.  See: [705](https://github.com/rails/webpacker/issues/705). Here's a more concise way to import a folder of images. Add this line to your code.

app/javascript/packs/application.js

```javascript
require.context('../../assets/images', true)
```

### 4. Use the `image_pack_tag` in your views with the conventional `media` prefix.

Now you're ready to use the `image_pack_tag` in the views. Here's an example.

app/views/hello/index.html.erb

```html
<div>Jets: <%= image_pack_tag("media/images/jets.png") %></div>
<div>Eric: <%= image_pack_tag("media/southpark/eric.png") %></div>
```

Notice the convention:

    app/assets/images/jets.png => image_pack_tag("media/images/jets.png")
    app/assets/images/southpark/jets.png => image_pack_tag("media/southpark/eric.png")

This is the current convention that webpack has chosen.

## Debugging Tip

To double-check that the assets are compiling correctly, run `bin/webpack` and check generated `manifest.json`

    $ bin/webpack
    $ grep media public/packs/manifest.json
      "media/images/jets.png": "/packs/media/images/jets-87771aa5.png",
      "media/southpark/eric.png": "/packs/media/southpark/eric-6809100c.png",
      "media/southpark/stan.png": "/packs/media/southpark/stan-91559ff6.png",
    $

## Cache Headers

The Jets default max-age for assets serving out of s3 is 3600s or 1h. When using webpacker, since the sha checksums are added, it makes sense to use longer TTLs. Here's an example:

```ruby
Jets.application.configure do
  # ...
  # Default assets settings
  config.assets.folders = %w[assets images packs]
  config.assets.max_age = 3600 # max_age is a short way to set cache_control and expands to cache_control="public, max-age=3600"
  # config.assets.cache_control = nil # IE: "public, max-age=3600" # override max_age for more fine-grain control.
  # config.assets.base_url = nil # IE: https://cloudfront.com/my/base/path, defaults to the s3 bucket url
                                 # IE: https://s3-us-west-2.amazonaws.com/demo-dev-s3bucket-1inlzkvujq8zb
end
```

## Deploying

Jets will automatically upload images in `public/packs` to s3 by default. See the `assets.folders` setting at [Config References]({% link _docs/app-config/reference.md %}).  Jets has also decorated the `image_pack_tag` so assets will be served from the s3 bucket.  Running:

    jets deploy

And viewing the html source should show something like this:

```html
<img src="https://s3-us-west-2.amazonaws.com/demo-dev-s3bucket-11hmo46sdaczc/jets/public/packs/media/images/jets-87771aa5.png" />
<img src="https://s3-us-west-2.amazonaws.com/demo-dev-s3bucket-11hmo46sdaczc/jets/public/packs/media/southpark/eric-6809100c.png" />
<img src="https://s3-us-west-2.amazonaws.com/demo-dev-s3bucket-11hmo46sdaczc/jets/public/packs/media/southpark/stan-91559ff6.png" />
```

## Summary

Using webpack with assets gives you the benefit of performance and automation. It can take some time to set up, though, and debugging webpack can be difficult since the ecosystem tends to move fast. You are often times better off upgrading the tools like yarn, node, and updating the configuration files. For innovation, fast-moving technologies are generally a good thing.
