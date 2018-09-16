class Jets::Stack
  class Function
    attr_reader :template
    def initialize(template)
      @template = template
    end

    def lang
      attributes = @template.values.first
      handler = attributes['Properties']['Handler']

      path_expression = handler.split('.')[0..-2].join('.') + '.*'
      Dir.glob(path_expression)
    end
  end
end