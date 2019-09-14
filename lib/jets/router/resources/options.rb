module Jets::Router::Resources
  class Options < Base
    def build(action)
      controller = @options[:singular_resource] ? @name.to_s.pluralize : @name
      options = @options.merge(to: "#{controller}##{action}") # important to create a copy of the options
      # remove special options from getting to create_route. For some reason .slice! doesnt work
      options.delete(:only)
      options.delete(:except)
      options[:from_scope] = true # flag to drop the prefix later in Route#compute_path
      options
    end
  end
end
