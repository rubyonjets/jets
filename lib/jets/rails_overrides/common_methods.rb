module Jets::CommonMethods
  # Add API Gateway Stage Name
  def add_stage_name(url)
    puts "request.host #{request.host.inspect}".colorize(:cyan)
    puts "url #{url.inspect}".colorize(:cyan)
    if request.host.include?("amazonaws.com") &&
            url.starts_with?('/') &&
            !url.starts_with?('http')
      stage_name = [Jets.config.short_env, Jets.config.env_extra].compact.join('_').gsub('-','_') # Stage name only allows a-zA-Z0-9_
      url = "/#{stage_name}#{url}"
    end

    url
  end
end
