---
title: VPC
---

**Update 9/3/2019**: [Announcing improved VPC networking for AWS Lambda functions](https://aws.amazon.com/blogs/compute/announcing-improved-vpc-networking-for-aws-lambda-functions/). This removes the extra cold-start penalty associated with Lambda and VPC. It essentially moves the creation of the ENI to function creation time instead of invocation time.

These docs are kept around for posterity.

Though running your AWS Lambda functions within a VPC is supported, unless completely necessary, it is generally not recommended.  The reasons are:

* Slow AWS Lambda cold start.
* Slow deletion of ENI network cards.

## How VPC Config Mode Works

To understand some of the limits with VPC and AWS Lambda, let's briefly cover how it works. When you run your Lambda function, Lambda creates a network card and attaches it the "container" that your Lambda function runs within. This is how the Lambda function gets 1st class citizen access to VPC features. The Lambda function gets a dedicated network card.  Here's a diagram to explain the bootstrap process.

![](/img/docs/considerations/lambda-bootstrap-vpc.png)

## Slow Cold Start

How much time does the additional network card process take? Some have mentioned 10+ seconds!  [Prewarming]({% link _docs/prewarming.md %}) helps but 10+ is too slow for use cases like web requests. In my testing, the cold start took about 5-7 seconds.

![](/img/docs/considerations/lambda-vpc-cold-start.png)

## How to Configure VPC

To have your Lambda functions use a VPC, simply define its [Function Properties]({% link _docs/function-properties.md %}). Here's how you configure vpc_config as an application-wide function property:

```ruby
Jets.application.configure do
  config.function.vpc_config = {
    security_group_ids: %w[sg-1 sg-2],
    subnet_ids: %w[subnet-1 subnet-2],
  }
end
```

If `vpc_config` is configured at the application-wide level, Jets will automatically add the necessary VPC-related IAM permissions for you.

## NAT Gateway Required

The Lambda functions `vpc_config` need to contain private subnets that have a NAT Gateway. Public subnets with an Internet Gateway did not work when I tested. The Lambda function would time out.  The AWS Lambda console even has a message stating the requirement of a NAT Gateway:

![](/img/docs/considerations/vpc-config-nat-gateway.png)

## Slow Function Deletion

An additional disadvantage of VPC with Lambda is the deletion of the network card takes a while. Some have reported up to 40m! [VPC Lambda ENI - Stack Deletion Bug](https://forums.aws.amazon.com/message.jspa?messageID=734756) In my own testing, it took about 25m.  CloudFormation waits for the ENI deletion to complete, so it slows down the deploy.

![](/img/docs/considerations/lambda-vpc-delete-time.png)

Here's also the `jets deploy` messages:

    Deploying CloudFormation stack with jets app!
    05:59:41PM UPDATE_IN_PROGRESS AWS::CloudFormation::Stack demo-dev User Initiated
    05:59:46PM UPDATE_IN_PROGRESS AWS::CloudFormation::Stack HardJob
    06:01:05PM UPDATE_COMPLETE AWS::CloudFormation::Stack HardJob
    06:01:07PM UPDATE_COMPLETE_CLEANUP_IN_PROGRESS AWS::CloudFormation::Stack demo-dev
    06:01:08PM UPDATE_IN_PROGRESS AWS::CloudFormation::Stack HardJob
    06:25:49PM UPDATE_COMPLETE AWS::CloudFormation::Stack HardJob
    06:25:49PM UPDATE_COMPLETE AWS::CloudFormation::Stack demo-dev
    Stack success status: UPDATE_COMPLETE
    Time took for stack deployment: 26m 11s.

## Future Speed Improvements?

Note, this is just conjecture. It is rumored that AWS is working on speed improvements to the Lambda VPC slowness issues.

In the future, AWS Lambda might use some form of [network trunking](https://www.techopedia.com/definition/9775/trunking) and provision and destroy the network card only as needed. This is already an approach AWS has taken with [ECS awsvpcTrunking](https://aws.amazon.com/about-aws/whats-new/2019/06/Amazon-ECS-Improves-ENI-Density-Limits-for-awsvpc-Networking-Mode/).  Additionally, AWS will probably also speed up the network card deletion process itself.

