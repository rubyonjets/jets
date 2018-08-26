Essentially removes the CloudWatch groups assocated with the app. Lambda requests re-create the log groups so this is pretty safe to do.

## Example

    jets log:clean