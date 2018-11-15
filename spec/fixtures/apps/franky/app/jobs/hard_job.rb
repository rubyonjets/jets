class HardJob < ApplicationJob
  rate "10 hours" # every 10 hours
  def dig
    puts "done digging"
    {done: "digging"}
  end

  rate "8 hours" # every 8 hours
  def drive
    puts("event data: #{event.inspect}")
    {done: "driving"}
  end

  cron "0 */12 * * ? *" # every 12 hours
  def lift
    puts "done lifting"
    {done: "lifting"}
  end
end

# Configuring Job Rate
#
# AWS scheduled events supports a rate expression.  It takes a unit plus a
# unit of time. Valid units of times are: minute, minutes, hour, hours, day, days
# Rate expression examples:
#
# every 1 minute:
#   rate: "1 minute"
#
# everyday:
#   cron: "1 day"
#
# AWS supports their own cron-like expression. AWS Cron expressions examples:
#
# every day at 12:00pm UTC:
#   cron: "0 12 * * ? *"
#
# every day, at 5 and 35 minutes past 2:00pm UTC:
#   cron: "5,35 14 * * ? *"
#
# 10:15am UTC on the last Friday of each month during the years 2002 to 2005:
#   cron: "15 10 ? * 6L 2002-2005"
#
# Sample Data
#
# All job methods have the `event` and `context` available. Here's an example of what that data looks like:
#
# event:
#   {
#     "account": "123456789012",
#     "region": "us-east-1",
#     "detail": {},
#     "detail-type": "Scheduled Event",
#     "source": "aws.events",
#     "time": "1970-01-01T00:00:00Z",
#     "id": "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c",
#     "resources": [
#       "arn:aws:events:us-east-1:123456789012:rule/my-schedule"
#     ]
#   }
#
# context:
#   {
#     "callbackWaitsForEmptyEventLoop": true,
#     "logGroupName": "/aws/lambda/demo-dev-2-posts-controller-new",
#     "logStreamName": "2017/11/07/[$LATEST]3cefcb18a8bc49acbfb3f29907a36391",
#     "functionName": "demo-dev-2-posts-controller-new",
#     "memoryLimitInMB": "3008",
#     "functionVersion": "$LATEST",
#     "invokeid": "cd68b58a-c379-11e7-bab1-855c4fa0d379",
#     "awsRequestId": "cd68b58a-c379-11e7-bab1-855c4fa0d379",
#     "invokedFunctionArn":
#     "arn:aws:lambda:us-east-1:123456789012:function:demo-dev-2-posts-controller-new"
#   }
#
# For more info: http://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
