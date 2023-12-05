module Jets::Controller::Decorate
  module ApigwStage
    def add_apigw_stage(url)
      return url unless add_apigw_stage?
      stage_name = ENV['JETS_APIGW_STAGE'] || Jets::Cfn::Resource::ApiGateway::Deployment.stage_name
      uri = URI.parse(url)
      path = uri.path
      original_ends_with_slash = path.ends_with?('/')
      path = "/#{path}" unless path.starts_with?('/')
      segments = path.split('/')
      # unless to prevent stage name being added twice if url_for is called twice on the same string
      segments.insert(1, stage_name) unless segments[1] == stage_name
      new_path = segments.join('/') # modified path
      new_path = "#{new_path}/" if !new_path.ends_with?('/') && original_ends_with_slash
      uri.path = new_path
      uri.to_s
    end

    def add_apigw_stage?
      return true if ENV['JETS_APIGW_STAGE']
      return false if ENV['JETS_TEST']
      return false unless request # nil for `importmap json` cli and actionmailer

      # Using request.host which might be different than event['headers']['Host'] when config.app.domain is set.
      # This means that visiting the APIGW domain name directly will not prepend the stage name
      # to the helper method urls.  This is ok since the APIGW domain name is not used in production.
      # It's a compromise since we cannot pass the CloudFront host to APIGW.
      # Rather have the CloudFront user-friendly domain name work than APIGW domain name.
      # Examples:
      #   https://djvojd3em5.execute-api.us-west-2.amazonaws.com/dev/
      #   https://friendly.domain.com/
      host = request.host
      on_cloud9 = !!(host =~ /cloud9\..*\.amazonaws\.com/)
      return false if on_cloud9

      host.include?('amazonaws.com')
    end
  end
end
