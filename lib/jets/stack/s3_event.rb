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
      # closures
      configure_bucket = unless Jets.config.s3_event.configure_bucket.nil?
        puts "DEPRECATION WARNING: Jets.config.s3_event.configure_bucket is deprecated. Please use Jets.config.events.s3.configure_bucket instead."
        Jets.config.s3_event.configure_bucket
      else
        Jets.config.events.s3.configure_bucket
      end

      notification_configuration = unless Jets.config.s3_event.notification_configuration.nil?
        puts "DEPRECATION WARNING: Jets.config.s3_event.notification_configuration is deprecated. Please use Jets.config.events.s3.notification_configuration instead."
        Jets.config.s3_event.notification_configuration
      else
        Jets.config.events.s3.notification_configuration
      end

      Jets::Stack.new_class(stack_name) do
        s3_bucket_configuration(:S3BucketConfiguration,
          ServiceToken: "!GetAtt JetsS3BucketConfig.Arn", # Cannot change this w/o changing the logical id
          # These properties correspond to the ruby aws-sdk s3.put_bucket_notification_configuration
          # in jets/s3_bucket_config.rb, not the CloudFormation Bucket properties. The CloudFormation
          # bucket properties have a similiar structure but is slightly different so it can be confusing.
          #
          #   Ruby aws-sdk S3 Docs: https://amzn.to/2N7m5Lr
          Bucket: bucket,
          NotificationConfiguration: notification_configuration,
        ) if configure_bucket

        # Important note: If we change the name of this function we should also change the
        # logical id of the s3_bucket_configuration custom resource or we'll get this error:
        #   Modifying service token is not allowed.
        function("jets/s3_bucket_config",
          Role: "!GetAtt BucketConfigIamRole.Arn",
          Layers: ["!Ref GemLayer"],
        )

        sns_topic(:SnsTopic)
        sns_topic_policy(:SnsTopicPolicy,
          PolicyDocument: {
            Version: "2012-10-17",
            Statement: {
              Effect: "Allow",
              Principal: { Service: "s3.amazonaws.com"},
              Action: "sns:Publish",
              Resource: "!Ref SnsTopic",
              Condition: {
                ArnLike: {
                  "Aws:SourceArn" => "!Sub arn:aws:s3:*:*:#{bucket}"
                }
              }
            }
          },
          Topics: ["!Ref SnsTopic"],
        )

        iam_role(:BucketConfigIamRole,
          AssumeRolePolicyDocument: {
            Version: '2012-10-17',
            Statement: [
              Effect: "Allow",
              Principal: {Service: ["lambda.amazonaws.com"]},
              Action: ['sts:AssumeRole'],
            ]
          },
          Path: "/",
          ManagedPolicyArns: ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"],
          Policies: [
            PolicyName: "S3Policy",
            PolicyDocument: {
              Version: '2012-10-17',
              Statement: [
                Effect: "Allow",
                Action: [
                  's3:GetBucketNotification',
                  's3:PutBucketNotification',
                ],
                Resource: "*"
              ]
            }
          ]
        )
      end
    end
  end
end