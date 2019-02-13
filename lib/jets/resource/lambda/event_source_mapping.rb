# Note the Lambda function timeout must be less than or equal to the sqs queue default timeout.
module Jets::Resource::Lambda
  class EventSourceMapping < Jets::Resource::Base
    def initialize(props={})
      @props = props # associated_properties from dsl.rb
    end

    def definition
      # CloudFormation Docs: https://amzn.to/2WM6165
      properties = {
        # batch_size: 10, # Defaults: Kinesis 100, DynamoDB Streams: 100, SQS: 10
        # enabled: boolean,
        # event_source_arn: string, # required
        function_name: "!Ref {namespace}LambdaFunction",
        # starting_position: string # reqiured for Required for Amazon Kinesis and Amazon DynamoDB Streams sources
      }
      properties.merge!(@props)

      {
        event_source_mapping_logical_id => {
          type: "AWS::Lambda::EventSourceMapping",
          properties: properties
        }
      }
    end

    def event_source_mapping_logical_id
      "{namespace}EventSourceMapping"
    end
  end
end