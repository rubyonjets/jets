module Jets::Resource::Sns
  class Topic < Jets::Resource::Base
    @@counter = 0
    def initialize(shared_class, definition)
      @shared_class = shared_class.to_s
      @definition = definition # always full definition
    end

    def definition
      @definition # contains the user defined logical id
      user_logical_id = @definition.keys.first

      logical_id = topic_logical_id(user_logical_id)
      puts "logical_id #{logical_id}".colorize(:cyan)

      # brand new definition
      base = {
        logical_id => {
          type: "AWS::Sns::Topic",
          properties: {}
        }
      }
      properties = @definition.values.first[:properties]
      base[logical_id][:properties].deep_merge!(properties)
      base
    end

    def topic_logical_id(user_logical_id)
      shared_class = @shared_class.underscore
      ["shared_#{shared_class}_#{user_logical_id}", counter].compact.join('_')
    end

    def counter
      @@counter += 1
      @@counter > 1 ? @@counter : nil
    end
    memoize :counter
  end
end
