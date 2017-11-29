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

    cfn.delete_stack(stack_name: parent_stack_name)
    puts "Project #{Jets.config.project_namespace} deleted!"
  end

  def confirm_project_exists
    begin
      resp = cfn.describe_stacks(stack_name: parent_stack_name)
    rescue Aws::CloudFormation::Errors::ValidationError
      # Aws::CloudFormation::Errors::ValidationError is thrown when the stack
      # does not exist
      puts "Config #{Jets.config.project_namespace} does not exist. So it cannot be deleted."
      exit 0
    end
  end

  def empty_s3_bucket
    return unless s3_bucket_name # Happens when minimal stack fails to build

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

  def parent_stack_name
    Jets::Naming.parent_stack_name
  end

  def are_you_sure?
    if @options[:force]
      sure = 'y'
    else
      puts "Are you sure you want to want to delete the '#{Jets.config.project_namespace}' project? (y/N)"
      sure = $stdin.gets
    end

    unless sure =~ /^y/
      puts "Phew! Config was not deleted."
      exit 0
    end
  end
end
