---
title: CloudWatch Logs Search
---

CloudWatch search field might look like a simple plain text search box but it is not. The search filter supports some advanced Filter and Pattern matching syntax. More info here on the AWS Docs: [Filter and Pattern Syntax](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html).

This might be confusing behavior for new users thinking it's a plain text search box. If you want to search for a specific string, surround it by double quotes.

    "my text search"

vs

    my text search

The 2 expressions work differently. The terms in the latter are OR together.  If you do not surround it by double quotes, then you are adding OR clauses, and the results will increase instead of decrease.

## CloudWatch Filtering Tip

Sometimes you do not want to see entries in CloudWatch Logs. Let say you are looking for the event payload and would like to exclude a specific IP address.  You can use the `-` (minus sign) to exclude it.

    Event - "11.22.33.44"

We're searching for "Event" and are excluding "11.22.33.44". Here's an example screenshot:

![](/img/docs/cloudwatch-search-exclude.png)

It then becomes powerful to combine multiple negative filters to help you focus and narrow down to the issue you're diagnosing. Example of multiple filters:

    Event - "11.22.33.44" - "Mozilla/5.0

Filtering out noise that you do not want to see when you are trying to focus on debugging your specific issue can be very helpful.

