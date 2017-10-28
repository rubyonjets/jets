require "aws-sdk"

class Jets::Fly
  include Jets::Cfn::AwsServices

  def initialize(options)
    @options = options
  end

  def run
    puts "Deploying project to Lambda..."
    deploy
  end

  def deploy
    first_run = first_run?
    stack_options = get_stack_options(first_run)
    options = @options.merge(stack_options)

    Jets::Build.new(options).run
    Jets::Cfn::Deploy.new(options).run

    deploy if first_run # re-deploy again
  end

private
  def get_stack_options(first_run)
    if first_run
      puts "FIRST RUN"
      {stack_type: "minimal"}
    else
      puts "SECOND RUN"
      resp = cfn.describe_stacks(stack_name: parent_stack_name)
      output = resp.stacks[0].outputs.find {|o| o.output_key == 'S3Bucket'}
      s3_bucket = output.output_value
      {stack_type: "full", s3_bucket: s3_bucket}
    end
  end

  # Important to not cache this. Must always return a fresh status.
  def first_run?
    !stack_exists?(parent_stack_name)
  end

  def parent_stack_name
    Jets::Cfn::Namer.parent_stack_name
  end
end
