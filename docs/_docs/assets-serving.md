---
title: Assets Serving
---

Jets handle asset serving by uploading asset files to s3 and serving them directly from s3. This is particularly beneficial for binary assets as they are s3 is better suited for serving them.

By default, these folders are automatically uploaded to s3 as part of the `jets deploy` command:

Folder | Description
--- | ---
public/packs | Where `app/javascript` webpacker assets are compiled to.
public/assets | Additional custom assets you might have.
public/images | Public images.

You can override the setting and configure the folders with the [Application Configuration]({% link _docs/app-config.md %}).

```ruby
Jets.application.configure do
  # ...
  # Default assets settings
  config.assets.folders = %w[packs images assets]
  config.assets.base_url = nil # IE: https://cloudfront.com/my/base/path
  config.assets.max_age = 3600
  config.assets.cache_control = nil # max_age is a shorter way to set cache_control
end
```

<a id="prev" class="btn btn-basic" href="{% link _docs/cors-support.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/action-filters.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
