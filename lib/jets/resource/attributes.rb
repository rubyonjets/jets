module Jets::Resource
  class Attributes
    extend Memoist

    def initialize(data, task, replacements={})
      @data = data
      @task = task
      @replacements = replacements
    end

    def logical_id
      id = @data.keys.first
      # replace possible {namespace} in the logical id
      id = replacer.replace_value(id)
      Jets::Pascalize.pascalize_string(id)
    end

    def type
      attributes['Type']
    end

    def properties
      attributes['Properties']
    end

    def attributes
      attributes = @data.values.first
      attributes = replacer.replace_placeholders(attributes, @replacements)
      Jets::Pascalize.pascalize(attributes)
    end

    def replacer
      # TODO: look up replace dynamically
      Replacer::ConfigRule.new(@task)
    end
    memoize :replacer

    def permission
      Permission.new(@task, self)
    end
    memoize :permission
  end
end
