require 'bundler/setup'
require 'active_support/core_ext/hash'
require 'cfn_response'

def lambda_handler(event:, context:)
  cfn = CfnResponse.new(event, context)
  cfn.response do
    case event['RequestType']
    when "Create", "Update"
      properties = event["ResourceProperties"].dup
      # After deleting ServiceToken, the rest of the values are the bucket configuration properties.
      properties.delete("ServiceToken")
      configurator = BucketConfigurator.new
      configurator.put(properties)
    end
  end
end

########################################################
require "aws-sdk-s3"

class BucketConfigurator
  def put(props={})
    # all props including bucket gets passed from the Custom::S3BucketConfiguration resource
    props = props.deep_transform_keys { |k| k.to_s.underscore.to_sym }
    puts "props: #{JSON.dump(props)}"
    s3.put_bucket_notification_configuration(props)
  end

  def s3
    @s3 ||= Aws::S3::Client.new
  end
end
