module Jets::Job::Dsl
  module S3Event
    def s3_event(bucket_name, props={})
      stack_name = declare_s3_bucket_resources(bucket_name) # only set up once per bucket
      declare_sns_subscription(topic_arn: "!Ref #{stack_name}SnsTopic") # set up subscription every time
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

    def s3_events
      Jets::Job::Base.s3_events
    end
  end
end
