# Override to prepend stage name when on AWS.
module Jets::AssetTagHelper
  extend Memoist
  include Jets::CommonMethods
  include Jets::AwsServices

  def javascript_include_tag(*sources, **options)
    sources = sources.map { |s| s3_public_url(s, :javascripts) }
    super
  end

  def stylesheet_link_tag(*sources, **options)
    sources = sources.map { |s| s3_public_url(s, :stylesheets) }
    super
  end

  # Locally:
  #
  #   image_tag("jets.png") => /images/jets.png
  #   image_tag("/images/jets.png") => /images/jets.png
  #
  # Remotely:
  #
  #   image_tag("jets.png") => https://s3-us-west-2.amazonaws.com/demo-dev-s3bucket-1kih4n2te0n66/jets/public/images/jets.png
  def image_tag(source, options = {})
    # mimic original behavior to get /images in source
    source = "/images/#{source}" unless source.starts_with?('/')
    if on_aws?(source)
      source = "#{s3_public}#{source}"
    end

    super
  end

  def asset_path(source, options = {})
    if on_aws?(source) && asset_folder?(source)
      # mimic original behavior to get /images in source
      source = "/images/#{source}" unless source.starts_with?('/')
      source = "#{s3_public}#{source}"
    end

    super
  end

private
  # Whatever is configured in Jets.config.assets.folders
  # Example: packs, images, assets
  def asset_folder?(url)
    Jets.config.assets.folders.detect do |folder|
      url.include?(folder)
    end
  end

  # User can use:
  #  javascript_include_tag "assets/test"
  #
  # Rails automatically adds "javscript" in front, to become:
  #
  #   /javascripts/assets/test
  #
  # We want to add the API Gateway stage name in front for this:
  #
  #   /stag/javascript/asset/test
  #
  # But adding it in front results in this:
  #
  #   /javascript/stag/asset/test
  #
  # If there's a / in front then rails will not add the "javascript":
  # So we can add the javascript ourselves and then add the stag with a
  # / in front.
  def s3_public_url(url, asset_type)
    unless url.starts_with?('/') or url.starts_with?('http')
      url = "/#{asset_type}/#{url}" # /javascript/asset/test
    end
    add_s3_public(url)
  end

  # Example:
  # Url: /packs/application-e7654c50abd78161b641.js
  # Returns: https://s3-us-west-2.amazonaws.com/demo-dev-s3bucket-1jg5o076egkk4/jets/public/packs/application-e7654c50abd78161b641.js
  def add_s3_public(url)
    return url unless on_aws?(url)
    "#{s3_public}#{url}"
  end

  def s3_public
    # s3_base_url.txt is created as part of the build process
    s3_base_url = IO.read("#{Jets.root}config/s3_base_url.txt").strip
    "#{s3_base_url}/public"
  end
  memoize :s3_public
end
ActionView::Helpers.send(:include, Jets::AssetTagHelper)
