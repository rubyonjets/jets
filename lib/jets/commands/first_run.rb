module Jets::Commands::FirstRun
  include Jets::AwsServices

  def first_run?
    !stack_exists?(parent_stack_name)
  end

  def merge_build_options!
    if first_run?
      @options.merge!(stack_type: "minimal")
    else
      resp = check_updatable_status # exit if stack status is not in an updated able state
      output = resp.stacks[0].outputs.find {|o| o.output_key == 'S3Bucket'}
      s3_bucket = output.output_value
      @options.merge!(stack_type: "full", s3_bucket: s3_bucket)
    end
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
