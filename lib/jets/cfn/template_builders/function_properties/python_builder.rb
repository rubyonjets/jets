module Jets::Cfn::TemplateBuilders::FunctionProperties
  class PythonBuilder < BaseBuilder
    def default_handler
      @task.poly_handler_value(:handle) # IE: handlers/controllers/posts/show.handle
    end

    # https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime
    def default_runtime
      "python3.6"
    end
  end
end
