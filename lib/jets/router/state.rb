class Jets::Router
  class State
    extend Memoist
    include Jets::AwsServices

    def load(filename)
      resp = s3.get_object(
        bucket: Jets.aws.s3_bucket,
        key: s3_storage_path(filename),
      )
      text = resp.body.read
      JSON.load(text)
    rescue
    end
    memoize :load

    # Save previously deployed APIGW routes state
    def save(filename, data)
      # body = Jets::Router.routes.to_json
      # body = JSON.generate(Jets::Cfn::Builders::PageBuilder.pages)
      body = data.respond_to?(:to_json) ? data.to_json : JSON.generate(data)
      s3.put_object(
        body: body,
        bucket: Jets.aws.s3_bucket,
        key: s3_storage_path(filename),
      )
    end

    # Examples:
    #
    #   jets/state/apigw/pages.json
    #   jets/state/apigw/routes.json
    #
    # Fetch or loaded in:
    #
    #   pages.json: Jets::Cfn::Builders::PageBuilder#old_pages
    #   routes.json: Jets::Resource::ApiGateway::RestApi::Routes::Change::Base#deployed_routes
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
