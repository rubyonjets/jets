class Jets::Delete
  include Jets::Cfn::AwsServices

  def initialize(options)
    @options = options
  end

  def run
    puts "Deleting project..."
    # TODO: add an are you sure prompt
    return if @options[:noop]

    # First remove all objects form s3 bucket
    resp = cfn.describe_stacks(stack_name: parent_stack_name)
    output = resp.stacks[0].outputs.find {|o| o.output_key == 'S3Bucket'}
    s3_bucket = output.output_value
    empty_bucket(s3_bucket)

    # Then delete the parent stack
    cfn.delete_stack(stack_name: parent_stack_name)
    puts "Stack #{parent_stack_name} deleted!"
  end

  def parent_stack_name
    Jets::Cfn::Namer.parent_stack_name
  end

  def empty_bucket(bucket_name)
    resp = s3.list_objects(bucket: bucket_name, max_keys: 3)
    if resp.contents.size > 0
      # IE: objects = [{key: "objectkey1"}, {key: "objectkey2"}]
      objects = resp.contents.map { |item| {key: item.key} }
      s3.delete_objects(
        bucket: bucket_name,
        delete: {
          objects: objects,
          quiet: false,
        }
      )
      empty_bucket(bucket_name) # keep deleting objects until bucket is empty
    end
  end
end
