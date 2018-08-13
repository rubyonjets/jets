module Jets::Cfn::TemplateBuilders::FunctionProperties
  class PythonBuilder < BaseBuilder
    def default_handler
      @task.full_handler(:lambda_handler) # IE: handlers/controllers/posts/show.lambda_handler
    end

    # https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime
    def default_runtime
      "python3.6"
    end
  end
end
