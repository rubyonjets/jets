# SqsEvent uses this module
module Jets::Job::Dsl
  module EventSourceMapping
    def event_source_mapping(props={})
      r = Jets::Resource::Lambda::EventSourceMapping.new(props)
      with_fresh_properties do
        resource(r.definition) # add associated resource immediately
      end
    end
  end
end
