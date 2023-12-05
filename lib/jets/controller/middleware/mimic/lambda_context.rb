class Jets::Controller::Middleware::Mimic
  # This class uses method_missing to mimic for all possible future methods
  # that AWS Lambda might add to the context object.
  #
  # The current methods available on the Lambda Context object:
  #   aws_request_id, invoked_function_arn, log_group_name,
  #   log_stream_name, function_name, memory_limit_in_mb, function_version,
  #   identity, client_context, deadline_ms
  #
  # Locally, example mimic values:
  #
  #   context.aws_request_id "mimic lambda context: aws_request_id"
  #   context.invoked_function_arn "mimic lambda context: invoked_function_arn"
  #   context.log_group_name "mimic lambda context: log_group_name"
  #   context.log_stream_name "mimic lambda context: log_stream_name"
  #   context.function_name "mimic lambda context: function_name"
  #   context.memory_limit_in_mb "mimic lambda context: memory_limit_in_mb"
  #   context.function_version "mimic lambda context: function_version"
  #   context.identity "mimic lambda context: identity"
  #   context.client_context "mimic lambda context: client_context"
  #   context.deadline_ms "mimic lambda context: deadline_ms"
  #
  # On AWS, example real values:
  #
  #   context.aws_request_id "b8357b1d-15f2-4197-9c6b-d6873be5eaba"
  #   context.invoked_function_arn "arn:aws:lambda:us-west-2:112233445566:function:demo-dev-controller"
  #   context.log_group_name "/aws/lambda/demo-dev-controller"
  #   context.log_stream_name "2023/09/10/[$LATEST]18323c481c674665b25496c329daa382"
  #   context.function_name "demo-dev-controller"
  #   context.memory_limit_in_mb "1536"
  #   context.function_version "$LATEST"
  #   context.identity nil
  #   context.client_context nil
  #   context.deadline_ms 1694353587386
  #
  class LambdaContext
    def initialize(*)
    end

    def method_missing(method_name, *args)
      "mimic lambda context: #{method_name}"
    end
  end
end
