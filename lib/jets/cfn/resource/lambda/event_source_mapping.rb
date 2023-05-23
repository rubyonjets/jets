# Note the Lambda function timeout must be less than or equal to the sqs queue default timeout.
module Jets::Cfn::Resource::Lambda
  class EventSourceMapping < Jets::Cfn::Base
    def initialize(props={})
      @props = props # associated_properties from dsl.rb
    end

    def definition
      # CloudFormation Docs: https://amzn.to/2WM6165
      properties = {
        # BatchSize: 10, # Defaults: Kinesis 100, DynamoDB Streams: 100, SQS: 10
        # Enabled: boolean,
        # EventSourceArn: string, # required
        FunctionName: "!Ref {namespace}LambdaFunction",
        # StartingPosition: string # reqiured for Required for Amazon Kinesis and Amazon DynamoDB Streams sources
      }
      properties.merge!(@props)

      {
        event_source_mapping_logical_id => {
          Type: "AWS::Lambda::EventSourceMapping",
          Properties: properties
        }
      }
    end

    def event_source_mapping_logical_id
      "{namespace}EventSourceMapping"
    end
  end
end