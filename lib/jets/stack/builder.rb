class Jets::Stack
  class Builder
    extend Memoist

    def initialize(stack)
      @stack = stack
      @template = {} # will build this structure up
    end

    def template
      build_section(:parameters)
      build_section(:resources)
      build_section(:outputs)
      Jets::Camelizer.transform(@template)
    end
    memoize :template

    def build_section(section)
      elements = build_elements(section)
      return unless elements

      if section == :parameters
        elements["GemLayer"] = {"Type"=>"String"} unless Jets.poly_only?
      end
      @template[section] = elements
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
