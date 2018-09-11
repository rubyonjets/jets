module Jets::Resource::Sns
  class Topic < Jets::Resource::Base
    @@counter = 0
    def initialize(definition)
      @definition = definition
    end

    def definition
      base = {
        topic_logical_id => {
          type: "AWS::Sns::Topic",
          properties: {}
        }
      }

      if full_definition?
        base.deep_merge!(@definition)
      else
        base[topic_logical_id][:properties].deep_merge!(@definition) # definition is just properties
      end
      base
    end

    def full_definition?
      @definition.keys.size == 1 && @definition.values.key?(:type)
    end

    def topic_logical_id
      ["shared_sns_topic", counter].compact.join('_')
    end

    def counter
      @@counter += 1
      @@counter > 1 ? @@counter : nil
    end
    memoize :counter
  end
end
