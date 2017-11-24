class Jets::Deploy
  include Jets::AwsServices

  def initialize(options)
    @options = options
  end

  def run
    puts "Deploying project to Lambda..."
    return if @options[:noop]
    deploy
  end

  def deploy
    if first_run?
      deploy_minimal_stack
      deploy_full_stack
    else
      deploy_full_stack
    end
  end

  def deploy_minimal_stack
    Jets::Build.new(stack_options).build_minimal_stack
    Jets::Cfn::Ship.new(stack_options).run
  end

  def deploy_full_stack
    Jets::Build.new(stack_options).run
    Jets::Cfn::Ship.new(stack_options).run
  end

private
  def stack_options
    stack_options = if first_run?
        {stack_type: "minimal"}
      else
        resp = check_updatable_status # exit if stack status is not in an updated able state
        output = resp.stacks[0].outputs.find {|o| o.output_key == 'S3Bucket'}
        s3_bucket = output.output_value
        {stack_type: "full", s3_bucket: s3_bucket}
      end

    @options.merge(stack_options)
  end

  def first_run?
    return @first_run if @first_run_determined

    @first_run = !stack_exists?(parent_stack_name)
    @first_run_determined = true
    @first_run
  end
  alias_method :first_run, :first_run?

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
      puts "The '#{parent_stack_name}' stack status is #{status}. " \
           "It is not in an updateable status. Please wait until the stack is ready and try again.".colorize(:red)
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
