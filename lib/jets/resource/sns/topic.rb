module Jets::Resource::Sns
  class Topic < Jets::Resource::Base
    @@counter = 0
    def initialize(definition)
      @definition = definition
    end

    def definition
      @definition # contains the user defined logical id
      definition = @definition.clone

      base = {
        topic_logical_id => {
          type: "AWS::Sns::Topic",
          properties: {}
        }
      }
      base.deep_merge!(@definition)

      if full_definition?
        base.deep_merge!(@definition)
      else
        base[topic_logical_id][:properties].deep_merge!(@definition) # definition is just properties
      end
      base
    end

    def full_definition?
      only_one_top_level_key = @definition.keys.size == 1
      possible_attributes = @definition.values.first

      attributes_at_second_level = possible_attributes.is_a?(Hash) && possible_attributes.key?(:type)

      only_one_top_level_key && attributes_at_second_level
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
