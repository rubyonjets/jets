class Jets::Commands::Delete
  include Jets::AwsServices

  def initialize(options)
    @options = options
  end

  def run
    puts("Deleting project...")
    return if @options[:noop]

    are_you_sure?

    confirm_project_exists

    # Must first remove all objects from s3 bucket in order to delete stack
    puts "First, deleting objects in s3 bucket #{s3_bucket_name}" if s3_bucket_name
    empty_s3_bucket

    stack_in_progress?(parent_stack_name)

    cfn.delete_stack(stack_name: parent_stack_name)
    puts "Deleting #{Jets.config.project_namespace.color(:green)}..."

    wait_for_stack if @options[:wait]

    delete_logs

    puts "Project #{Jets.config.project_namespace.color(:green)} deleted!"
  end

  def wait_for_stack
    status = Jets::Cfn::Status.new(@options)
    start_time = Time.now
    status.wait
    took = Time.now - start_time
    puts "Time took for deletion: #{status.pretty_time(took).color(:green)}."
  end

  def delete_logs
    puts "Deleting CloudWatch logs"
    log = Jets::Commands::Clean::Log.new(mute: true, yes: true)
    log.clean
  end

  def confirm_project_exists
    retries = 0
    begin
      cfn.describe_stacks(stack_name: parent_stack_name)
    rescue Aws::CloudFormation::Errors::ValidationError
      # Aws::CloudFormation::Errors::ValidationError is thrown when the stack
      # does not exist
      puts "The parent stack #{Jets.config.project_namespace.color(:green)} for the project #{Jets.config.project_name.color(:green)} does not exist. So it cannot be deleted."
      exit 0
    rescue Aws::CloudFormation::Errors::Throttling => e
      retries += 1
      seconds = 2 ** retries

      puts "WARN: confirm_project_exists #{e.class} #{e.message}".color(:yellow)
      puts "Backing off and will retry in #{seconds} seconds."
      sleep(seconds)
      if seconds > 90 # 2 ** 6 is 64 so will give up after 6 retries
        puts "Giving up after #{retries} retries"
      else
        retry
      end
    end
  end

  def empty_s3_bucket
    return unless s3_bucket_name # Happens when minimal stack fails to build
    return unless bucket_exists?(s3_bucket_name)

    resp = s3.list_objects(bucket: s3_bucket_name)
    if resp.contents.size > 0
      # IE: objects = [{key: "objectkey1"}, {key: "objectkey2"}]
      objects = resp.contents.map { |item| {key: item.key} }
      s3.delete_objects(
        bucket: s3_bucket_name,
        delete: {
          objects: objects,
          quiet: false,
        }
      )
      empty_s3_bucket # keep deleting objects until bucket is empty
    end
  end

  def s3_bucket_name
    return @s3_bucket_name if defined?(@s3_bucket_name)

    resp = cfn.describe_stacks(stack_name: parent_stack_name)
    outputs = resp.stacks[0].outputs
    if outputs.empty?
      @s3_bucket_name = false
    else
      @s3_bucket_name = outputs.find {|o| o.output_key == 'S3Bucket'}.output_value
    end
  end

  # Thanks: https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/s3-example-does-bucket-exist.html
  def bucket_exists?(bucket_name)
    bucket_exists = false
    begin
      resp = s3.head_bucket(bucket: bucket_name, use_accelerate_endpoint: false)
      bucket_exists = true
    rescue
    end
    bucket_exists
  end

  def parent_stack_name
    Jets::Naming.parent_stack_name
  end

  def are_you_sure?
    if @options[:yes]
      sure = 'y'
    else
      puts "Are you sure you want to want to delete the #{Jets.config.project_namespace.color(:green)} project? (y/N)"
      sure = $stdin.gets
    end

    unless sure =~ /^y/
      puts "Phew! Jets #{Jets.config.project_namespace.color(:green)} project was not deleted."
      exit 0
    end
  end

    # All CloudFormation states listed here: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-describing-stacks.html
    #
    # Returns resp so we can use it to grab data about the stack without calling api again.
    def check_deleteable_status
      return true if !stack_exists?(@parent_stack_name)

      # Assumes stack exists
      resp = cfn.describe_stacks(stack_name: @parent_stack_name)
      status = resp.stacks[0].stack_status

      return true if status == 'ROLLBACK_COMPLETE'

      if status =~ /_IN_PROGRESS$/
        puts "The '#{@parent_stack_name}' stack status is #{status}. " \
             "It is not in an updateable status. Please wait until the stack is ready and try again.".color(:red)
        exit 0
      elsif resp.stacks[0].outputs.empty?
        # This Happens when the miminal stack fails at the very beginning.
        # There is no s3 bucket at all.  User should delete the stack.
        puts "The minimal stack failed to create. Please delete the stack first and try again. " \
        "You can delete the CloudFormation stack or use the `jets delete` command"
        exit 0
      else
        true
      end
    end
end
