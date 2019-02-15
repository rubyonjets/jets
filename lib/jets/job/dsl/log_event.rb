module Jets::Job::Dsl
  module LogEvent
    def log_event(log_group_name, props={})
      props.merge!(log_group_name: log_group_name)
      declare_log_subscription_filter(props)
    end

    def declare_log_subscription_filter(props={})
      r = Jets::Resource::Logs::SubscriptionFilter.new(props)
      with_fresh_properties do
        resource(r.definition) # add associated resource immediately
      end
    end
  end
end
