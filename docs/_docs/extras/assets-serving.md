---
title: Assets Serving
---

Jets handles asset serving by uploading asset files to s3 and serving them directly from s3. This is particularly beneficial for binary assets like images as s3 is better suited for serving them.

Using the `asset_path` helper will serve the assets in the public folder from the filesystem locally and from s3 remotely. By default, the `public` folder is automatically uploaded to s3 as part of the `jets deploy` command.  Here are some notable folders within the `public` folder.

Folder | Description | Checksum
--- | --- | ---
public/packs | Where webpacker assets are compiled to. You defined js and css files in `app/javascript/packs` and webpacker will compile, add checksums to the file names and save them to `public/packs`. You can also create images in `app/javascript/images` and have webpacker add the checksum to the images files. | Yes
public/assets | Additional custom assets you might have. | No
public/images | Public images. | No

## Example with asset_path

app/views/layouts/application.html:

```erb
<link rel="stylesheet" href="<%= asset_path("/assets/my-min-asset.css") %>">
```

When deployed to lambda, the file is served out of s3 and looks like this:

```html
<link rel="stylesheet" href="https://s3-us-west-2.amazonaws.com/demo-dev-s3bucket-6nnjmcsxgjrx/jets/public/assets/my-min-asset.css">
```

## Caching Considerations

Even though `public/assets` and `public/images` files are uploaded and served for convenience.  There's a cavaet with the approach. The files in the `public/assets` and `public/images` do not get sha checksum added to their paths.  This makes it more difficult to cache the assets with longer TTLs. Even with short TTLs, some browsers and devices like iPhone seem to cache images indefinitely.  Consider using webpacker for your assets so that sha checksum are include as part of the path. Note, webpacker has it's own cavaets. See: [Assets Serving: Webpack]({% link _docs/extras/assets/webpacker.md %}).

## Configure Settings

You can override the setting and configure the folders with the [Application Configuration]({% link _docs/app-config.md %}).

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

