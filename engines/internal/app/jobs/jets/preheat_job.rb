class Jets::PreheatJob < Jets::Job::Base
  include Jets::AwsServices

  class_timeout 30
  class_memory 1024
  class_iam_policy([
    {
      Sid: "Statement1",
      Action: ["logs:*"],
      Effect: "Allow",
      Resource: [{
        "Fn::Sub": "arn:aws:logs:${AWS::Region}:${AWS::AccountId}:log-group:/aws/lambda/${JetsPreheatJobWarmLambdaFunction}"
      }]
    },
    {
      Sid: "Statement2",
      Action: ["lambda:InvokeFunction", "lambda:InvokeAsync"],
      Effect: "Allow",
      Resource: [{
        "Fn::Sub": "arn:aws:lambda:${AWS::Region}:${AWS::AccountId}:function:#{Jets.project_namespace}-*"
      }]
    }
  ])

  rate(Jets.config.prewarm.rate) if Jets.config.prewarm.enable
  def warm
    options = call_options(event[:quiet])
    Jets::Preheat.warm_all(options)
    "Finished prewarming your application."
  end

  class << self
    # Can use this to prewarm post deploy
    def prewarm!
      perform_now(:warm, quiet: true)
    end
  end

private
  # Usually: jets-preheat_job-warm unless JETS_RESET=1, in that case need to lookup the function name
  def warm_function_name
    # Return early to avoid lookup call normally
    return "jets-preheat_job-warm" unless ENV['JETS_RESET'] == "1"

    parent_stack = cfn.describe_stack_resources(stack_name: Jets::Names.parent_stack_name)
    preheat_stack = parent_stack.stack_resources.find do |resource|
      resource.logical_resource_id =~ /JetsPreheatJob/
    end

    resp = cfn.describe_stack_resources(stack_name: preheat_stack.physical_resource_id)
    resources = resp.stack_resources
    warm_function = resources.find do |resource|
      resource.logical_resource_id =~ /WarmLambdaFunction/
    end
    warm_function.physical_resource_id # IE: jets-preheat_job-warm
  end

  def call_options(quiet)
    options = {}
    options.merge!(mute: true, mute_output: true) if quiet
    # All the methods in this Job class leads to Jets::Commands::Call.
    # This is true for the Jets::Preheat.warm_all also.
    # These jobs delegate out to Lambda function calls. We do not need/want
    # the invocation type: RequestResponse in this case.
    options.merge!(invocation_type: "Event")
    options
  end
end
