module Jets::Cfn::TemplateBuilders::FunctionProperties
  class NodeBuilder < BaseBuilder
    def default_handler
      map.handler_value(:handle) # IE: handlers/controllers/posts_controllers.handle
    end

    def default_runtime
      "nodejs8.10"
    end
  end
end