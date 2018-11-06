---
title: Assets Serving
---

Jets handles asset serving by uploading asset files to s3 and serving them directly from s3. This is particularly beneficial for binary assets like images as s3 is better suited for serving them.

Using the `asset_path` helper will serve the assets in the public folder from the filesystem locally and from s3 remotely. By default, the `public` folder is automatically uploaded to s3 as part of the `jets deploy` command.  Here are some notable folders within the `public` folder.

Folder | Description | Checksum
--- | --- | ---
public/packs | Where webpacker assets are compiled to. You defined js and css files in `app/javascript/packs` and webpacker will compile, add checkums to the file names and save them to `public/packs`. You can also create images in `app/javascript/images` and have webpacker add the checksum to the images files. | Yes
public/assets | Additional custom assets you might have. | No
public/images | Public images. | No

## Caching Considerations

Even though `public/assets` and `public/images` files are uploaded and served for convenience.  It is recommended that you put your files in `app/javascript/images` and allow webpacker to compile, sha the assets, and save them to `public/packs`.  The files in `public/packs` contain checksums, whereas files in the `public/assets` and `public/images` do not get their sha checksum added to their paths.

By using webpacker, it generates unique file paths each time the file changes.  Then you will be able to configure high values for the `max-age` response header to further improve performance. This article [Increasing Application Performance with HTTP Cache Headers](https://devcenter.heroku.com/articles/increasing-application-performance-with-http-cache-headers) covers how cache headers work.  The default max age for assets serving out of s3 is 3600s or 1h.

## Configure Settings

You can override the setting and configure the folders with the [Application Configuration]({% link _docs/app-config.md %}).

```ruby
Jets.application.configure do
  # ...
  # Default assets settings
  config.assets.folders = %w[public]
  config.assets.max_age = 3600 # max_age is a short way to set cache_control and expands to cache_control="public, max-age=3600"
  # config.assets.cache_control = nil # IE: "public, max-age=3600" # override max_age for more fine-grain control.
  # config.assets.base_url = nil # IE: https://cloudfront.com/my/base/path, defaults to the s3 bucket url
                                 # IE: https://s3-us-west-2.amazonaws.com/demo-dev-s3bucket-1inlzkvujq8zb
end
```

<a id="prev" class="btn btn-basic" href="{% link _docs/cors-support.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/action-filters.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
