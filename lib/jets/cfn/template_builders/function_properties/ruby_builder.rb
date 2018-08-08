module Jets::Cfn::TemplateBuilders::FunctionProperties
  class RubyBuilder < BaseBuilder
    def default_runtime
      "nodejs8.10" # using node shim for ruby support
    end

    # Override this in subclasses like PythonBuilder.
    # Dynamically generated handler.
    def default_handler
      map.handler # IE: handlers/controllers/posts_controllers.index
    end
  end
end