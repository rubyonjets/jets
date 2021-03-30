---
title: Kinesis Events
categories: events
---

Jets supports [Kinesis Events](https://docs.aws.amazon.com/lambda/latest/dg/with-kinesis.html) as a Lambda trigger. You can use Lambda to process the data from Kinesis. The Lambda function has access to the stream data via `event` and `kinesis_data`.

<div class="video-box"><div class="video-container"><iframe src="https://www.youtube.com/embed/unvfrnhAVzg" frameborder="0" allowfullscreen=""></iframe></div></div>

## Example

Here is an example connecting an existing Kinesis stream to a Lambda function in a [Job]({% link _docs/jobs.md %}).

```ruby
class DataJob < ApplicationJob
  kinesis_event "my-stream" # existing stream
  def file
    puts "event #{JSON.dump(event)}"
    puts "kinesis_data #{JSON.dump(kinesis_data)}"
  end
end
```

Here's the Lambda function with Kinesis as a trigger.

![](/img/docs/kinesis-lambda.png)

You can also check that the Lambda function is connected to Kinesis via the [aws lambda list-event-source-mappings](https://docs.aws.amazon.com/cli/latest/reference/lambda/list-event-source-mappings.html):

    $ aws lambda list-event-source-mappings
    {
        "EventSourceMappings": [
            {
                "UUID": "861c866f-356a-4dba-9191-6ed853118fba",
                "StateTransitionReason": "User action",
                "LastModified": 1550287680.0,
                "BatchSize": 100,
                "State": "Enabled",
                "FunctionArn": "arn:aws:lambda:us-west-2:112233445566:function:demo-dev-data_job-file",
                "EventSourceArn": "arn:aws:kinesis:us-west-2:112233445566:stream/my-stream",
                "LastProcessingResult": "OK"
            }
        ]
    }
    $

## Send Test Data

Here's an example of sending the data:

    aws kinesis put-record --stream-name my-stream --partition-key 1 --data "hello world"

## Event Payload

The event payload from CloudWatch Log is a base64 encoded String within a JSON structure.  Here's an example to help explain:

### event

```json
{
    "Records": [
        {
            "kinesis": {
                "kinesisSchemaVersion": "1.0",
                "partitionKey": "1",
                "sequenceNumber": "49593016666855735301798073856083438124424404568371101698",
                "data": "aGVsbG8gd29ybGQ=",
                "approximateArrivalTimestamp": 1550289189.474
            },
            "eventSource": "aws:kinesis",
            "eventVersion": "1.0",
            "eventID": "shardId-000000000000:49593016666855735301798073856083438124424404568371101698",
            "eventName": "aws:kinesis:record",
            "invokeIdentityArn": "arn:aws:iam::112233445566:role/demo-dev-DataJob-OUD26QSQSWKN-DataJobFileIamRole-CM2L7G0KZVY",
            "awsRegion": "us-west-2",
            "eventSourceARN": "arn:aws:kinesis:us-west-2:112233445566:stream/my-stream"
        }
    ]
}
```

### kinesis_data

```ruby
["hello world"]
```

Here the data `aGVsbG8gd29ybGQ=` is `hello world`.  Example:

    $ echo "aGVsbG8gd29ybGQ=" | base64 -d
    hello world

Since there can be multiple records, kinesis_data is an Array that contains the unencoded data of each element.

Here's a screenshot of the event in the CloudWatch Log console.

![](/img/docs/kinesis-log.png)

## Create Stream Example

Here's an example of creating a kinesis stream via the CLI:

    aws kinesis create-stream --stream-name my-stream --shard-count 1

## IAM Policy

Jets generates an IAM policy for the Lambda function associated with the Kinesis event that allows the permissions needed.  You can control and override the IAM policy with normal [IAM Policies]({% link _docs/iam-policies.md %}) if required, though.

