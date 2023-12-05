module Jets::Router
  class State
    extend Memoist
    include Jets::AwsServices

    def self.save_apigw_state
      state = Jets::Router::State.new
      state.save("methods", Jets::Cfn::Builder::Api::Pages::Methods.pages)
      state.save("resources", Jets::Cfn::Builder::Api::Pages::Resources.pages)
      # To avoid API limits for calculating changed routes in next deploy
      state.save("routes", Jets::Router.routes)
    end

    def load(filename)
      resp = nil
      begin
        resp = s3.get_object(
          bucket: Jets.aws.s3_bucket,
          key: s3_storage_path(filename),
        )
      rescue Aws::S3::Errors::NoSuchBucket
        # Allow JETS_TEMPLATES=1 jets build to work with no-bucket-yet
        return nil
      end
      text = resp.body.read
      JSON.load(text)
    rescue Aws::S3::Errors::NoSuchKey, Aws::S3::Errors::PermanentRedirect
    end
    memoize :load

    # Save previously deployed APIGW routes state
    def save(filename, data)
      body = data.respond_to?(:to_json) ? data.to_json : JSON.generate(data)
      body = JSON.pretty_generate(JSON.parse(body)) # pretty generate
      if ENV['JETS_API_STATE_DEBUG'] # useful with jets build --templates
        puts "WARN: JETS_API_STATE_DEBUG=1 detected. Saving to tmp/#{filename}.json instead of S3.".color(:yellow)
        IO.write("tmp/#{filename}.json", body)
      else
        s3.put_object(
          body: body,
          bucket: Jets.aws.s3_bucket,
          key: s3_storage_path(filename),
        )
      end
    end

    # Examples:
    #
    #   jets/state/apigw/resources.json
    #   jets/state/apigw/methods.json
    #   jets/state/apigw/routes.json
    #
    # Fetch or loaded in:
    #
    #   resources.json: Jets::Cfn::Builder::Api::Pages::Resources#old_pages
    #   methods.json:   Jets::Cfn::Builder::Api::Pages::Methods#old_pages
    #   routes.json:    Jets::Cfn::Resource::ApiGateway::RestApi::Routes::Change::Base#deployed_routes
    #
    # Saved in:
    #
    #   Jets::Cfn::Ship#save_apigw_state
    #
    def s3_storage_path(filename)
      "jets/state/apigw/#{filename}.json"
    end
  end
end
