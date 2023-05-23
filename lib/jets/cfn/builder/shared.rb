class Jets::Cfn::Builder
  class Shared < Nested
    # interface method
    def compose
      stack = @app_class.new # @app_class is subclass. IE: Alarm < Jets::Stack
      builder = Jets::Stack::Builder.new(stack)
      @template = builder.template # overwrite entire @template
    end

    # interface method
    def template_path
      Jets::Names.shared_template_path(@app_class)
    end
  end
end
