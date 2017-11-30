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

    resp = cfn.describe_stacks(stack_name: parent_stack_name)
    output = resp.stacks[0].outputs.find {|o| o.output_key == 'S3Bucket'}
    @s3_bucket = output.output_value # once an s3 bucket is found, cache it
  end

  # Always call API
  def first_run?
    !stack_exists?(parent_stack_name)
  end

  def parent_stack_name
    Jets::Naming.parent_stack_name
  end
end
