module Jets::Router::Resources
  class Options < Base
    def build(action)
      # Important to create a copy of the options since we are mutating it
      # The original options are used for resources and resource scope
      options = @options.dup
      # Remove special options from getting to create_route. For some reason .slice! doesnt work
      options.delete(:only)
      options.delete(:except)
      controller = options[:singular_resource] ? @name.to_s.pluralize : @name
      options[:to] = "#{controller}##{action}"
      options
    end
  end
end
