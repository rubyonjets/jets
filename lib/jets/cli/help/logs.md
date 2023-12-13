Show logs from Lambda function CloudWatch log group.

This defaults to the controller Lambda function.  Example:

    ❯ jets logs
    Showing logs for /aws/lambda/demo-dev-controller

If you want to follow the logs use the `-f` flag.

    ❯ jets logs -f
    Tailing logs for /aws/lambda/demo-dev-controller

If you want to see the production logs:

    ❯ JETS_ENV=prod jets logs -f
    Tailing logs for /aws/lambda/demo-prod-controller

If you want to see logs for a job, specify the job and method.

    ❯ jets logs -f -n hard_job-dig
    Tailing logs for /aws/lambda/demo-dev-hard_job-dig
