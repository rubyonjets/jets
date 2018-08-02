module Jets::Cfn::TemplateBuilders::FunctionProperties
  class NodeBuilder < BaseBuilder
    def default_handler
      map.poly_handler_value(:handle) # IE: handlers/controllers/posts/show.handle
    end

    # https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime
    def default_runtime
      "nodejs8.10"
    end
  end
end