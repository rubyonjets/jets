# Override to prepend stage name when on AWS.
module JetsTurbines
  module AssetTagHelper
    extend Memoist
    include Jets::Controller::Decorate::ApigwStage
    include Jets::AwsServices

    # All paths lead to here: path_to_asset / asset_path
    # Examples:
    #
    #   javascript_include_tag => path_to_javascript => path_to_asset
    #   stylesheet_link_tag => path_to_stylesheet => path_to_asset
    #   image_tag => path_to_image => path_to_asset
    #
    # Also note: Tried using compute_path but that does not always get reached.
    # IE: jetpacker will copute sources for manifest before calling javascript_include_tag
    #
    #   javascript_include_tag(*sources_from_manifest_entries...)
    # On the other hand, path_to_asset is always called.
    def asset_path(source, options = {})
      path = super
      # Decorate path and prepend with s3 url when on AWS Lambda
      # This serves assets out of s3 when on AWS Lambda.
      path = prepend_s3_jets_public(path)
      path
    end
    alias_method :path_to_asset, :asset_path
    # Note: Must alias path_to_asset again because asset_path conflicts with an asset_path named route
    # Otherwise, method is not called.
    # Rails does this internally also.

    # Serves favicon out of s3 when on API gateway.
    #
    # Useful helper for API Gateway since serving binary data like images without
    # an Accept header doesnt work well. You can changed Media Types to '*/*'
    # but then that messes up form data.
    #
    # This is Jets specific and not part of Rails. It was in the orignal Jets v3 codebase.
    # Example usage:
    #   <link rel="shortcut icon" href="<%= favicon_path %>">
    #   public/favicon.ico
    # Since Jets v5, you can also use asset_path helper and put the asset in app/assets/images
    # Example:
    #   <link rel="shortcut icon" href="<%= asset_path('favicon.ico') %>">
    #   app/assets/images/favicon.ico
    #
    def favicon_path(path='favicon.ico')
      add_s3_public? ? "#{s3_public}/#{path}" : "/#{path}"
    end

  private
    def prepend_s3_jets_public(asset_path)
      if add_s3_public? && !asset_path.starts_with?('http')
        asset_path = "#{s3_public}#{asset_path}"
      end
      asset_path
    end

    def add_s3_public?
      !!ENV['_HANDLER'] # only add s3 public when on AWS Lambda
    end

    def s3_public
      # s3_base_url.txt is created as part of the build and deploy process
      s3_base_url = IO.read("#{Jets.root}/config/s3_base_url.txt").strip
      "#{s3_base_url}/public"
    end
    memoize :s3_public
  end
end
