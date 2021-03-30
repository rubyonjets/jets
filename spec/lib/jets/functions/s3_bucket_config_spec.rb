ENV['CFN_RESPONSE_SEND'] = '1'
ENV['CFN_RESPONSE_VERBOSE'] = '0'
require "ostruct"

code = IO.read("./lib/jets/internal/app/shared/functions/jets/s3_bucket_config.rb")
# Hack: Seems to be the only way to mimic access the methods by include Cfnresponse like send_response
eval %Q{
  class MainScope
    #{code}
  end
}

describe "s3_bucket_config" do
   before do
     # https://rubyrailroad.com/2014/01/23/how-to-ignore-ruby-puts-in-rspec-tests/
     allow($stdout).to receive(:write)
   end

  let(:event) do
    {
      "RequestType" => "Create",
      "ServiceToken" => "arn:aws:lambda:us-west-2:112233445566:function:demo-dev-my-bucket-s3_bucket_config",
      "ResponseURL" => "https://cloudformation-custom-resource-response-uswest2.s3-us-west-2.amazonaws.com/arn-blah",
      "StackId" => "arn:aws:cloudformation:us-west-2:112233445566:stack/blah",
      "RequestId" => "61318e12-6c1a-44c4-bd8f-ce0b34f32026",
      "LogicalResourceId" => "MyBucketS3BucketConfiguration",
      "ResourceType" => "Custom::S3BucketConfiguration",
      "ResourceProperties" => {
        "ServiceToken" => "arn:aws:lambda:us-west-2:112233445566:function:demo-dev-my-bucket-s3_bucket_config",
        "Bucket" => "my-bucket",
        "NotificationConfiguration" => {
          "TopicConfigurations" => [
            {
              "Events" => [ "s3:ObjectCreated:*"],
              "TopicArn" => "sns:arn:topic",
            },
          ],
        }
      }
    }
  end
  let(:context) do
    OpenStruct.new(log_group_name: "fake-log-group", log_stream_name: "fake-log-stream")
  end
  let(:main) do
    MainScope.new
  end

  it "BucketConfigurator" do
    main.lambda_handler(event: event, context: context)
  end
end
