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

  def add_s3_base_url(url)
    "#{s3_base_url}#{url}"
  end

  def s3_base_url
    resp = cfn.describe_stacks(stack_name: Jets::Naming.parent_stack_name)
    stack = resp.stacks.first
    output = stack["outputs"].find { |o| o["output_key"] == "S3Bucket" }
    bucket_name = output["output_value"] # s3_bucket
    region = Aws.account.region
    # TOOD: FIX URL
    asset_base_url = Jets.config.asset_base_url || "https://#{region}-s3.aws.amazon.com"
    "#{asset_base_url}/#{bucket_name}"
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
