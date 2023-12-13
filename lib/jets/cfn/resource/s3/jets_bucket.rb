module Jets::Cfn::Resource::S3
  class JetsBucket < Bucket
    def initialize
      @bucket_logical_id = "S3Bucket"
      @props = props
    end

    def props
      props = {
        PublicAccessBlockConfiguration: {
          BlockPublicAcls: false
          # BlockPublicPolicy: false,
          # IgnorePublicAcls: false,
          # RestrictPublicBuckets: false
        },
        OwnershipControls: {
          Rules: [{ObjectOwnership: "ObjectWriter"}]
        },
        BucketEncryption: {
          ServerSideEncryptionConfiguration: [
            ServerSideEncryptionByDefault: {
              SSEAlgorithm: "AES256"
            }
          ]
        }
      }
      # CorsConfiguration to allow assets to serve from the bucket
      props[:CorsConfiguration] = Jets.bootstrap.config.s3_bucket.cors_configuration
      props
    end

    class << self
      include Jets::AwsServices

      # Usage:
      #   Jets::Cfn::Resource::S3::JetsBucket.name
      @@name = nil
      def name
        return @@name if @@name
        return "fake-bucket" if ENV["JETS_NO_INTERNET"] || ENV["JETS_TEMPLATES"]

        resp = nil
        begin
          resp = cfn.describe_stacks(stack_name: Jets::Names.parent_stack_name)
        rescue Aws::CloudFormation::Errors::ValidationError => e
          if e.message.include?("does not exist")
            return "no-bucket-yet" # for jets build without s3 bucket yet
          else
            raise
          end
        end

        output = resp.stacks[0].outputs.find { |o| o.output_key == "S3Bucket" }
        # The output can be nil if the stack failed and is in rollback state
        @@name = output.output_value if output # cache only once found
      end
    end
  end
end
