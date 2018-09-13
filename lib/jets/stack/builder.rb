class Jets::Stack
  class Builder
    def initialize(stack)
      @stack = stack
    end

    def template
      template = {
        parameters: build(:parameters),
        resources: build(:resources),
        outputs: build(:outputs),
      }
      Jets::Camelizer.transform(template)
    end

    def build(section)
      # s is a "section part".  Examples:
      #
      #   Jets::Stack::Parameter
      #   Jets::Stack::Resource
      #   Jets::Stack::Output
      #
      @stack.send(section).inject({}) do |template_section, s|
        template_section.merge(s.template)
      end
    end
  end
end
