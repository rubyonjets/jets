# Override to prepend stage name when on AWS.
module Jets::AssetTagHelper
  extend Memoist
  include Jets::CommonMethods
  include Jets::AwsServices

  def javascript_include_tag(*sources, **options)
    sources = sources.map { |s| s3_asset_url(s, :javascripts) }
    super
  end

  def stylesheet_link_tag(*sources, **options)
    sources = sources.map { |s| s3_asset_url(s, :stylesheets) }
    super
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
  def s3_asset_url(url, asset_type)
    unless url.starts_with?('/') or url.starts_with?('http')
      url = "/#{asset_type}/#{url}" # /javascript/asset/test
    end
    url = add_s3_base_url(url)
    url
  end

  # Example:
  # Url: /packs/application-e7654c50abd78161b641.js
  # Returns: https://s3-us-west-2.amazonaws.com/demo-dev-s3bucket-1jg5o076egkk4/jets/public/packs/application-e7654c50abd78161b641.js
  def add_s3_base_url(url)
    return url unless on_aws?(url)
    "#{s3_base_url}#{url}"
  end

  def on_aws?(url)
    request.host.include?("amazonaws.com") &&
      url.starts_with?('/') &&
      !url.starts_with?('http')
  end

  # TODO: figure out how to improve performance.
  def s3_base_url
    IO.read("#{Jets.root}/config/s3_base_url.txt").strip
  end
  memoize :s3_base_url

  # # User can use:
  # #  javascript_include_tag "assets/test"
  # #
  # # Rails automatically adds "javscript" in front, to become:
  # #
  # #   /javascripts/assets/test
  # #
  # # We want to add the API Gateway stage name in front for this:
  # #
  # #   /stag/javascript/asset/test
  # #
  # # But adding it in front results in this:
  # #
  # #   /javascript/stag/asset/test
  # #
  # # If there's a / in front then rails will not add the "javascript":
  # # So we can add the javascript ourselves and then add the stag with a
  # # / in front.
  # def stage_name_asset_url(url, asset_type)
  #   unless url.starts_with?('/') or url.starts_with?('http')
  #     url = "/#{asset_type}/#{url}" # /javascript/asset/test
  #   end
  #   url = add_stage_name(url)
  #   url
  # end
end
ActionView::Helpers.send(:include, Jets::AssetTagHelper)
