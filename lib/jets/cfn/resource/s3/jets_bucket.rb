module Jets::Cfn::Resource::S3
  class JetsBucket < Bucket
    def initialize
      @bucket_logical_id = "S3Bucket"
      @props = props
    end

    def props
      props = {
        PublicAccessBlockConfiguration: {
          BlockPublicAcls: false,
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
        },
      }
      props[:CorsConfiguration] = cors_configuration # dont check config.api.cors since javascript_importmap_tags also uses
      props
    end

    def cors_configuration
      Jets.config.api.s3_cors_configuration || {
        CorsRules: [{
          AllowedHeaders: ["*"],
          AllowedMethods: ["GET"],
          AllowedOrigins: ["*"],
          ExposedHeaders: [],
        }]
      }
    end

    class << self
      include Jets::AwsServices

      # Usage:
      #   Jets::Cfn::Resource::S3::JetsBucket.name
      @@name = nil
      def name
        return @@name if @@name
        return "fake-bucket" if ENV['JETS_NO_INTERNET'] || ENV['JETS_TEMPLATES']

        resp = nil
        begin
          resp = cfn.describe_stacks(stack_name: Jets::Names.parent_stack_name)
        rescue Aws::CloudFormation::Errors::ValidationError => e
          if e.message.include?('does not exist') && Jets::Command.original_cli_command == 'build' # jets build
            return "no-bucket-yet" # for jets build without s3 bucket yet
          else
            raise
          end
        end

        output = resp.stacks[0].outputs.find {|o| o.output_key == 'S3Bucket'}
        @@name = output.output_value # cache only once found
      end
    end
  end
end
