module Jets::Job::Dsl
  module DynamodbEvent
    def dynamodb_event(table_name, options={})
      return if ENV['JETS_BUILD_NO_INTERNET'] # Disable during build since jets build tries to init this

      stream_arn = full_dynamodb_stream_arn(table_name)
      default_iam_policy = default_dynamodb_stream_policy(stream_arn)

      # Create iam policy allows access to queue
      # Allow disabling in case use wants to add permission application-wide and not have extra IAM policy
      iam_policy_props = options.delete(:iam_policy) || @iam_policy || default_iam_policy
      iam_policy(iam_policy_props) unless iam_policy_props == :disable

      props = options # by this time options only has EventSourceMapping properties
      default = {
        event_source_arn: stream_arn,
        starting_position: "TRIM_HORIZON",
      }
      props = default.merge(props)

      event_source_mapping(props)
    end


    # Expands table name to the full stream arn. Example:
    #
    #   test-table
    # To:
    #   arn:aws:dynamodb:us-west-2:112233445566:table/test-table/stream/2019-02-15T21:41:15.217
    #
    # Note, this does not check if the stream has been disabled.
    def full_dynamodb_stream_arn(table_name)
      return table_name if table_name.include?("arn:aws:dynamodb") # assume full stream arn

      begin
        resp = dynamodb.describe_table(table_name: table_name)
      rescue Aws::DynamoDB::Errors::ResourceNotFoundException => e
        puts e.message
        puts "ERROR: Was not able to find the DynamoDB table: #{table_name}.".color(:red)
        code_line = caller.grep(%r{/app/jobs}).first
        puts "Please check: #{code_line}"
        puts "Exiting"
        exit 1
      end
      stream_arn = resp.table.latest_stream_arn
      return stream_arn if stream_arn
    end

    def default_dynamodb_stream_policy(stream_name_arn='*')
      stream = {
        action: ["dynamodb:GetRecords",
                 "dynamodb:GetShardIterator",
                 "dynamodb:DescribeStream",
                 "dynamodb:ListStreams"],
        effect: "Allow",
        resource: stream_name_arn,
      }
      table_name_arn = stream_name_arn.gsub(%r{/stream/20.*},'')
      table = {
        action: ["dynamodb:DescribeTable"],
        effect: "Allow",
        resource: table_name_arn,
      }
      [stream, table]
    end
  end
end