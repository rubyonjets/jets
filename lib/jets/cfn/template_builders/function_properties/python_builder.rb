module Jets::Cfn::TemplateBuilders::FunctionProperties
  class PythonBuilder < BaseBuilder
    def default_handler
      map.handler_value(:handle) # IE: handlers/controllers/posts_controllers.handle
    end

    def default_runtime
      "python3.6"
    end
  end
end
