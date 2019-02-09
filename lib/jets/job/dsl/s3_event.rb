module Jets::Job::Dsl
  module S3Event
    def s3_event(bucket_name, props={})
      if bucket_name.to_s =~ /generate/
        declare_sns_topic(props.delete(:topic_properties))
        declare_sns_topic_policy(props.delete(:topic_policy_properties))
        declare_s3_bucket(props) # add this point props only has s3 bucket properties
      elsif bucket_name.include?('!Ref') # reference shared resource
        # Add bucket configuration with Custom Resource
        # props = {bucket: bucket_name}.merge(props)
        # config_props = s3_bucket_configuration_properties(props)
        # puts "config_props #{config_props.inspect}"
        # declare_s3_bucket_configuration(config_props)

        # function_props = s3_lambda_function_properties({})
        # declare_lambda_function(function_props)
      else # existing bucket
        stack_name = declare_s3_bucket_resources(bucket_name) # only set up once per bucket
        declare_sns_subscription(topic_arn: "!Ref #{stack_name}SnsTopic") # set up subscription every time
      end
    end

    def s3_events
      Jets::Job::Base.s3_events
    end

    # Returns stack_name
    def declare_s3_bucket_resources(bucket_name)
      # If shared s3 bucket resources have already been declared.
      # We will not generate them again. However, we still need to always
      # add the depends_on declaration to ensure that the shared stack parameters
      # are properly passed to the nested child stack.
      stack_name = s3_events[bucket_name] # already registered
      if stack_name
        depends_on stack_name.underscore.to_sym, class_prefix: true # always add this
        return stack_name
      end

      # Create shared resources - one time
      stack_name = declare_shared_s3_event_resources(bucket_name)
      depends_on stack_name.underscore.to_sym, class_prefix: true # always add this
      self.s3_events[bucket_name] = stack_name # tracks buckets already set up
    end

    def declare_shared_s3_event_resources(bucket_name)
      s3_stack = Jets::Stack::S3Event.new(bucket_name)
      s3_stack.build_stack
      s3_stack.stack_name
    end

    def s3_bucket_configuration_properties(props={})
      sns_topic = props.delete(:sns_topic) # set earlier
      if sns_topic
        # default notification_configuration
        notification_configuration = {
          topic_configurations: [
            event: "s3:ObjectCreated:*",
            topic: sns_topic, # IE: !Ref LiftSnsTopic
          ]
        }
      end

      properties = {
        service_token: "!GetAtt S3BucketConfigurationLambdaFunction.Arn",
        # bucket: "...", # set by props
      }.merge(props)
      properties[:notification_configuration] ||= notification_configuration if notification_configuration
      properties
    end

    def s3_lambda_function_properties(props={})
    end

    def declare_s3_bucket_configuration(props={})
      r = Jets::Resource::S3::BucketConfiguration.new(props)
      with_fresh_properties do
        resource(r.definition) # add associated resource immediately
      end
    end

    def declare_s3_bucket(props={})
      # Event Notification Types and Destinations: https://docs.aws.amazon.com/AmazonS3/latest/dev/NotificationHowTo.html
      default = {
        notification_configuration: {
          topic_configurations: [
            event: "s3:ObjectCreated:*",
            topic: "!Ref {namespace}SnsTopic",
          ]
        }
      }
      props = default.merge(props)
      r = Jets::Resource::S3::Bucket.new(props)
      with_fresh_properties do
        resource(r.definition) # add associated resource immediately
      end
    end
  end
end
