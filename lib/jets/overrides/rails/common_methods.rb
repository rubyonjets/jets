module Jets::CommonMethods
  extend Memoist
  # Add API Gateway Stage Name
  def add_stage_name(url)
    return url unless add_stage?(url)

    stage_name = Jets::Resource::ApiGateway::Deployment.stage_name
    "/#{stage_name}#{url}"
  end

  def add_stage?(url)
    return false if on_cloud9?
    request.host.include?("amazonaws.com") && url.starts_with?('/')
  end
  memoize :add_stage?

  def on_aws?
    !request.headers['HTTP_X_AMZN_TRACE_ID'].nil? && !on_cloud9?
  end
  memoize :on_aws?

  def on_cloud9?
    !!(request.headers['HTTP_HOST'] =~ /cloud9\..*\.amazonaws\.com/)
  end
  memoize :on_cloud9?
end
