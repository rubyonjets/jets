module Jets::CommonMethods
  # Add API Gateway Stage Name
  def add_stage_name(url)
    return url unless on_aws?(url)

    stage_name = Jets::Resource::ApiGateway::Deployment.stage_name
    "/#{stage_name}#{url}"
  end

  def on_aws?(url)
    request.host.include?("amazonaws.com") && url.starts_with?('/')
  end
end
