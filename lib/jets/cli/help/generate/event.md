## Examples

    jets generate:event log --trigger log --method report
    jets generate:event cool --trigger scheduled
    jets generate:event security --trigger rule --method detect_security_group_changes
    jets generate:event clerk --trigger dynamodb --method file
    jets generate:event thermostat --trigger iot --method measure
    jets generate:event data --trigger kinesis --method file
    jets generate:event upload --trigger s3
    jets generate:event messenger --trigger sns --method deliver
    jets generate:event waiter --trigger sqs --method order
