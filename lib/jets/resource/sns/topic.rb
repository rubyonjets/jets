module Jets::Resource::Sns
  class Topic < Jets::Resource::Base
    @@counter = 0
    def initialize(shared_class, definition)
      @shared_class = shared_class.to_s
      @definition = definition # always full definition
    end

    def definition
      logical_id = topic_logical_id

      # brand new definition
      base = {
        logical_id => {
          type: "AWS::SNS::Topic",
          properties: {}
        }
      }
      properties = @definition.values.first[:properties]
      base[logical_id][:properties].deep_merge!(properties)
      base
    end

    def outputs
      {
        logical_id => "!Ref #{logical_id}",
      }
    end

    def topic_logical_id
      shared_class = @shared_class.underscore
      user_logical_id = @definition.keys.first
      ["shared_#{shared_class}_#{user_logical_id}", counter].compact.join('_')
    end

    def counter
      @@counter += 1
      @@counter > 1 ? @@counter : nil
    end
    memoize :counter
  end
end
