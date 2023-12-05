module Jets::Job::Dsl
  module DynamodbEvent
    def dynamodb_event(table_name_without_namespace, options={})
      return if ENV['JETS_BUILD_NO_INTERNET'] # Disable during build since jets build tries to init this

      table_name = add_dynamodb_table_namespace(table_name_without_namespace)
      stream_arn = full_dynamodb_stream_arn(table_name)
      default_iam_policy = default_dynamodb_stream_policy(stream_arn)

      # Create iam policy allows access to queue
      # Allow disabling in case use wants to add permission application-wide and not have extra IAM policy
      iam_policy_props = options.delete(:iam_policy) || @iam_policy || default_iam_policy
      iam_policy(iam_policy_props) unless iam_policy_props == :disable

      props = options # by this time options only has EventSourceMapping properties
      default = {
        EventSourceArn: stream_arn,
        StartingPosition: "TRIM_HORIZON",
      }
      props = default.merge(props)

      event_source_mapping(props)
    end

    def add_dynamodb_table_namespace(table_name_without_namespace)
      ns = if Jets.config.events.dynamodb.table_namespace == true
             Jets.table_namespace # does not include extra
           elsif Jets.config.events.dynamodb.table_namespace
             Jets.config.events.dynamodb.table_namespace # allow user to fully control namespace
           end
      ns_separator = Jets.config.events.dynamodb.table_namespace_separator
      [ns, table_name_without_namespace].compact.join(ns_separator)
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
        Action: ["dynamodb:GetRecords",
                 "dynamodb:GetShardIterator",
                 "dynamodb:DescribeStream",
                 "dynamodb:ListStreams"],
        Effect: "Allow",
        Resource: stream_name_arn,
      }
      table_name_arn = stream_name_arn.gsub(%r{/stream/20.*},'')
      table = {
        Action: ["dynamodb:DescribeTable"],
        Effect: "Allow",
        Resource: table_name_arn,
      }
      [stream, table]
    end
  end
end