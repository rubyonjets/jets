class Jets::Router
  module Util
    # used in MethodCreator logic
    def join(*items)
      list = items.compact.join('_')
      underscore(list)
    end

    def underscore(str)
      return unless str
      str.to_s.gsub(/[^a-zA-Z0-9]/,'_')
    end

    def get_controller_action(options)
      if options.key?(:controller) && options.key?(:action)
        [options[:controller], options[:action]]
      elsif options.key?(:controller) && options.key?(:to)
        action = options[:to].split('#').last
        [options[:controller], action]
      elsif options.key?(:on)
        handle_on!(options)
      else
        options[:to].split('#') # controller, action
      end
    end

    def handle_on!(options)
      controller = @scope.options[:prefix].to_s
      to = "#{controller}##{options[:path]}"
      options[:to] = to

      as = @options[:on] == :member ? controller.singularize : controller
      as = "#{@options[:path]}_#{as}"
      options[:as] = as
      to.split('#')
    end
  end
end