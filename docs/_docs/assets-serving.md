---
title: Assets Serving
---

Jets handles asset serving by uploading asset files to s3 and serving them directly from s3. This is particularly beneficial for binary assets like images as s3 is better suited for serving them.

By default, these folders are automatically uploaded to s3 as part of the `jets deploy` command:

Folder | Description
--- | ---
public/packs | Where `app/javascript` webpacker assets are compiled to.
public/assets | Additional custom assets you might have.
public/images | Public images.

Note: Even though `public/assets` and `public/images` files are uploaded and served for convenience.  It is recommended that you put your files in `app/javascript/images` and allow webpacker to compile and sha the assets. Webpacker generates and saves the files to `public/packs`. The files in `public/packs` contain checksums, whereas files in the `public/assets` and `public/images` do not get their sha checksum added to their paths.

By using webpacker, it generates unique file paths each time the file changes.  Then you will be able to configure high values for the `max-age` response header to further improve performance. This article [Increasing Application Performance with HTTP Cache Headers](https://devcenter.heroku.com/articles/increasing-application-performance-with-http-cache-headers) covers how cache headers work.

## Configure Settings

You can override the setting and configure the folders with the [Application Configuration]({% link _docs/app-config.md %}).

```ruby
Jets.application.configure do
  # ...
  # Default assets settings
  config.assets.folders = %w[public/assets public/images public/packs]
  config.assets.base_url = nil # IE: https://cloudfront.com/my/base/path
  config.assets.max_age = 3600
  config.assets.cache_control = nil # IE: public, max-age=3600 , max_age is a shorter way to set cache_control.
end
```

<a id="prev" class="btn btn-basic" href="{% link _docs/cors-support.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/action-filters.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
