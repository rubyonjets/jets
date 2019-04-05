class Jets::Stack
  class S3Event
    def initialize(bucket_name)
      @bucket_name = bucket_name
    end

    # Stack names can only contain alpha numeric chars.
    # Bucket names are limit to 64 chars: https://amzn.to/2SIzvme
    # Stack names are limit to 128 chars: https://amzn.to/2SFkrG0
    # This gsub should handle this.
    def stack_name
      @bucket_name.gsub(/[^0-9a-z\-_]/i, '').gsub('-','_').camelize
    end

    def build_stack
      # assign to local variable so its available in the block
      bucket = @bucket_name

      Jets::Stack.new_class(stack_name) do
        s3_bucket_configuration(:s3_bucket_configuration,
          service_token: "!GetAtt JetsS3BucketConfig.Arn", # Cannot change this w/o changing the logical id
          # These properties correspond to the ruby aws-sdk s3.put_bucket_notification_configuration
          # in jets/s3_bucket_config.rb, not the CloudFormation Bucket properties. The CloudFormation
          # bucket properties have a similiar structure but is slightly different so it can be confusing.
          #
          #   Ruby aws-sdk S3 Docs: https://amzn.to/2N7m5Lr
          bucket: bucket,
          notification_configuration: Jets.config.s3_event.notification_configuration,
        ) if Jets.config.s3_event.configure_bucket

        # Important note: If we change the name of this function we should also change the
        # logical id of the s3_bucket_configuration custom resource or we'll get this error:
        #   Modifying service token is not allowed.
        function("jets/s3_bucket_config",
          role: "!GetAtt BucketConfigIamRole.Arn",
          layers: ["!Ref GemLayer"],
        )

        sns_topic(:sns_topic)
        sns_topic_policy(:sns_topic_policy,
          policy_document: {
            version: "2012-10-17",
            statement: {
              effect: "Allow",
              principal: { service: "s3.amazonaws.com"},
              action: "sns:Publish",
              resource: "!Ref SnsTopic",
              condition: {
                arn_like: {
                  "aws:SourceArn" => "!Sub arn:aws:s3:*:*:#{bucket}"
                }
              }
            }
          },
          topics: ["!Ref SnsTopic"],
        )

        iam_role(:bucket_config_iam_role,
          assume_role_policy_document: {
            version: '2012-10-17',
            statement: [
              effect: "Allow",
              principal: {service: ["lambda.amazonaws.com"]},
              action: ['sts:AssumeRole'],
            ]
          },
          path: "/",
          managed_policy_arns: ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"],
          policies: [
            policy_name: "S3Policy",
            policy_document: {
              version: '2012-10-17',
              statement: [
                effect: "Allow",
                action: [
                  's3:GetBucketNotification',
                  's3:PutBucketNotification',
                ],
                resource: "*"
              ]
            }
          ]
        )
      end
    end
  end
end