module Jets::Job::Dsl
  module KinesisEvent
    def kinesis_event(stream_name, options={})
      stream_arn = full_kinesis_stream_arn(stream_name)
      default_iam_policy = default_kinesis_stream_policy(stream_arn)

      # Create iam policy allows access to queue
      # Allow disabling in case use wants to add permission application-wide and not have extra IAM policy
      iam_policy_props = options.delete(:iam_policy) || @iam_policy || default_iam_policy
      iam_policy(iam_policy_props) unless iam_policy_props == :disable

      props = options # by this time options only has EventSourceMapping properties
      default = {
        event_source_arn: stream_arn,
        starting_position: "LATEST",
      }
      props = default.merge(props)

      event_source_mapping(props)
    end

    # Expands table name to the full stream arn. Example:
    #
    #   test-table
    # To:
    #   arn:aws:kinesis:us-west-2:112233445566:table/test-table/stream/2019-02-15T21:41:15.217
    #
    # Note, this does not check if the stream has been disabled.
    def full_kinesis_stream_arn(stream_name)
      return stream_name if stream_name.include?("arn:aws:kinesis") # assume full stream arn

      "arn:aws:kinesis:#{Jets.aws.region}:#{Jets.aws.account}:stream/#{stream_name}"
    end

    def default_kinesis_stream_policy(stream_name_arn='*')
      {
        action: ["kinesis:GetRecords",
                 "kinesis:GetShardIterator",
                 "kinesis:DescribeStream",
                 "kinesis:ListStreams"],
        effect: "Allow",
        resource: stream_name_arn,
      }
    end
  end
end