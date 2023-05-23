module Jets::Stack::Main::Dsl
  module Kinesis
    def kinesis_stream(id, props={})
      defaults = {
        Name: id,
        ShardCount: 1
      }

      props = defaults.merge(props)

      resource(id, "AWS::Kinesis::Stream", props)
      output(id)
    end
  end
end
