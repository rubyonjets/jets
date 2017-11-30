# The important methods in this class are stack_type, s3_bucket and first_run?
# We use stack_type and s3_bucket to get info for both the build and deploy CLI
# commands.
# first_run? will always make an API call.
module Jets::Commands::StackInfo
  include Jets::AwsServices

  def stack_type
    first_run? ? :minimal : :full
  end

  def s3_bucket
    return @s3_bucket if @s3_bucket

    return nil if first_run?

    resp = check_updatable_status # exit if stack status is not in an updated able state
    output = resp.stacks[0].outputs.find {|o| o.output_key == 'S3Bucket'}
    @s3_bucket = output.output_value # once an s3 bucket is found, cache it
  end

  # Always call API
  def first_run?
    !stack_exists?(parent_stack_name)
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

  def parent_stack_name
    Jets::Naming.parent_stack_name
  end

end
