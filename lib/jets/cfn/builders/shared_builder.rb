module Jets::Cfn::Builders
  class SharedBuilder < BaseChildBuilder
    def compose
      stack = @app_class.new # @app_class is subclass. IE: Alarm < Jets::Stack
      builder = Jets::Stack::Builder.new(stack)
      @template = builder.template # overwrite entire @template
    end

    # template_path is an interface method for Interface module
    def template_path
      Jets::Naming.shared_template_path(@app_class)
    end
  end
end
