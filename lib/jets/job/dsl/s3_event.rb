module Jets::Job::Dsl
  module S3Event
    # Register an S3 event.
    # Allow custom sns_subscription_properties to be passed in.
    # Example:
    #
    #   props = { 
    #     sns_subscription_properties: {
    #       FilterPolicy: {
    #         field: [{ "prefix": "some_value" }]
    #       }.to_json
    #     }
    #   }
    #   s3_event("s3-bucket", props)
    #
    # The S3 event is set up with the following resources:
    #
    #   - S3 Bucket
    #   - S3 Bucket Notification Configuration
    #   - SNS Topic
    #   - SNS Subscription
    #
    # @param [String] bucket_name
    # @param [Hash] props
    def s3_event(bucket_name, props={})
      stack_name = declare_s3_bucket_resources(bucket_name) # only set up once per bucket
      sns_subscription_properties = {
        **props[:sns_subscription_properties] || {},
        TopicArn: "!Ref #{stack_name}SnsTopic"
      }

      declare_sns_subscription(sns_subscription_properties) # set up subscription every time
    end

    # Returns stack_name
    def declare_s3_bucket_resources(bucket_name)
      # If shared s3 bucket resources have already been declared.
      # We will not generate them again. However, we still need to always
      # add the depends_on declaration to ensure that the shared stack parameters
      # are properly passed to the nested child stack.
      stack_name = _s3_events[bucket_name] # already registered
      if stack_name
        depends_on stack_name.underscore.to_sym, class_prefix: true # always add this
        return stack_name
      end

      # Create shared resources - one time
      stack_name = declare_shared_s3_event_resources(bucket_name)
      depends_on stack_name.underscore.to_sym, class_prefix: true # always add this
      self._s3_events[bucket_name] = stack_name # tracks buckets already set up
    end

    def declare_shared_s3_event_resources(bucket_name)
      s3_stack = Jets::Stack::S3Event.new(bucket_name)
      s3_stack.build_stack
      s3_stack.stack_name
    end

    def _s3_events
      Jets::Job::Base._s3_events
    end
  end
end
