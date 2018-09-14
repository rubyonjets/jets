class Jets::Stack
  class Builder
    extend Memoist

    def initialize(stack)
      @stack = stack
    end

    def template
      template = {}
      build_section(template, :parameters)
      build_section(template, :resources)
      build_section(template, :outputs)
      Jets::Camelizer.transform(template)
    end
    memoize :template

    def build_section(template, section)
      elements = build_elements(section)
      template[section] = elements if elements
    end

    def build_elements(section)
      # s is a "section element".  Examples:
      #
      #   Jets::Stack::Parameter
      #   Jets::Stack::Resource
      #   Jets::Stack::Output
      #
      section_elements = @stack.send(section)
      return unless section_elements

      section_elements.inject({}) do |template_section, s|
        template_section.merge(s.template)
      end
    end
  end
end
