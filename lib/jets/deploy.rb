require "aws-sdk"

class Jets::Deploy
  include Jets::AwsServices

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
    Jets::Cfn::Ship.new(options).run

    deploy if first_run # re-deploy again
  end

private
  def get_stack_options(first_run)
    puts "parent_stack_name #{parent_stack_name}".colorize(:red)
    if first_run
      puts "FIRST RUN"
      {stack_type: "minimal"}
    else
      puts "SECOND RUN"
      resp = check_updatable_status # exit if stack status is not in an updated able state
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
    Jets::Naming.parent_stack_name
  end

  # All CloudFormation states listed here: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-describing-stacks.html
  #
  # Returns resp so we can use it to grab data about the stack without calling api again.
  def check_updatable_status
    # Assumes stack exists
    resp = cfn.describe_stacks(stack_name: parent_stack_name)
    status = resp.stacks[0].stack_status
    if status =~ /_IN_PROGRESS$/
      puts "The '#{parent_stack_name}' stack status is #{status}." \
           "It is not in an updateable status. Please check the stack and try again."
      exit 0
    elsif resp.stacks[0].outputs.empty?
      # This Happens when the miminal stack fails at the very beginning.
      # There is no s3 bucket at all.  User should delete the stack.
      puts "The minimal stack failed to create. Please delete the stack first and try again." \
      "You can delete the CloudFormation stack or use the `jets delete` command"
      exit 0
    else
      resp
    end
  end
end
