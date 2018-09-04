module Jets::CommonMethods
  # Add API Gateway Stage Name
  def add_stage_name(url)
    if request.host.include?("amazonaws.com") &&
            url.starts_with?('/') &&
            !url.starts_with?('http')
      stage_name = Jets::Resource::ApiGateway::Deployment.stage_name
      url = "/#{stage_name}#{url}"
    end

    url
  end
end
