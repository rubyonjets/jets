# Override to prepend stage name when on AWS.
module Jets::AssetTagHelper
  include Jets::CommonMethods

  def javascript_include_tag(*sources, **options)
    sources = sources.map { |s| stage_name_asset_url(s, :javascripts) }
    super
  end

  def stylesheet_link_tag(*sources, **options)
    sources = sources.map { |s| stage_name_asset_url(s, :stylesheets) }
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
  def stage_name_asset_url(url, asset_type)
    unless url.starts_with?('/') or url.starts_with?('http')
      url = "/#{asset_type}/#{url}" # /javascript/asset/test
    end
    url = add_stage_name(url)
    url
  end
end
ActionView::Helpers.send(:include, Jets::AssetTagHelper)
