require "active_support/all"
require "aws-sdk-s3"
require "cfnresponse"
include Cfnresponse

def lambda_handler(event:, context:)
  # Print out debugging info immediately just in case
  puts "event: #{json_pretty(event)}"
  puts "context: #{json_pretty(context)}"

  if %w[Create Update].include?(event['RequestType'])
    properties = event["ResourceProperties"].dup
    # After deleting ServiceToken, the rest of the values is the bucket configuration properties.
    properties.delete("ServiceToken")
    configurator = BucketConfigurator.new
    configurator.put(properties)
  end

  send_response(event, context, "SUCCESS")

# We rescue all exceptions and send an message to CloudFormation so we dont have to
# wait for over an hour for the stack operation to timeout and rollback.
rescue Exception => e
  puts e.message
  puts e.backtrace
  sleep 10 # a little time for logs to be sent to CloudWatch
  send_response(event, context, "FAILED")
end

########################################################

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
