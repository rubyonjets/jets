---
title: Custom Domain
nav_order: 32
---

Jets can create and associate a route53 custom domain with the API Gateway endpoint.  Jets manages the vanity route53 endpoint that points to the API Gateway endpoint.  It adjusts the endpoint transparently without you having to update your endpoint if Jets determines that a new API Gateway Rest API needs to be created. The route53 record is also updated. Here's a table with some example values to explain:

Vanity Endpoint | API Gateway Endpoint | Jets Env Extra
--- | --- | ---
dev-demo.coolapp.com | a02oy4fs56.execute-api.us-west-2.amazonaws.com | (not set)
dev-demo-2.coolapp.com | xyzoabc123.execute-api.us-west-2.amazonaws.com | 2

Here's a diagram also:

![](/img/docs/jets-vanity-endpoint.png)

## Vanity Endpoint

NOTE: If you have already previously set up an API Custom Domain, when Jets tries to add the Custom Domain it will fail. This is because the Custom Domain already exists, CloudFormation sees this, and will not destructively delete existing resources managed outside of its purview. Both the Custom Domain and the Route53 record associated with that domain must be delete before running `jets deploy`. This will occur downtime until the `jets deploy` completes. Fortunately, this only needs to be done once and after that Jets manages the vanity endpoint.  It is recommended that you set up the Custom Domain as early as possible so you do not run into this down the road.

To create a vanity endpoint edit the `config/application.rb` and edit `domain.cert_arn` and `domain.hosted_zone_name`:

```ruby
Jets.application.configure do
  config.domain.cert_arn = "arn:aws:acm:us-west-2:112233445577:certificate/8d8919ce-a710-4050-976b-b33da991e7e8" # String
  config.domain.hosted_zone_name = "coolapp.com" # String
  # config.domain.name = "#{Jets.project_namespace}.coolapp.com" # Default is the example convention
  # config.domain.route53 = true # false to disable route53 from being managed by jets.
      # The domain.route53 seetting defaults to true if if a hosted_zone_name is set.
      # It might be useful to turn of route53 if you are managing the DNS yourself.

  # NOTE: Changing the endpoint_configuration can result 10 minutes of downtime if going from REGIONAL to EDGE
  # config.domain.endpoint_configuration = { types: ["REGIONAL"] } # EDGE or REGIONAL
end
```

You can create an AWS Certificate with ACM by following the docs: [Request a Public Certificate](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html). The hosted zone name on Route53 is required. Here are the docs to create one: [Creating a Public Hosted Zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html).

## Controlling Domain Name

By default, the domain name is a subdomain with `Jets.project_namespace` as the value. Example:

    #{Jets.project_namespace}.coolapp.com = demo-dev.coolapp.com

When `JETS_ENV_EXTRA=1` is set the values looks like this:

    #{Jets.project_namespace}.coolapp.com = demo-dev-1.coolapp.com

You can set the domain name yourself and override the default behavior like so:

```ruby
Jets.application.configure do
  config.domain.name = "mysubdomain.coolapp.com"
end
```

## Changing Endpoint Configuration Warning

If you change the API Gateway [domain endpoint_type](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-apigateway-domainname-endpointconfiguration.html) REGIONAL to EDGE and vice versa, this results in downtime while the new endpoint type is being created.

* Going from REGIONAL to EDGE results in about **10 minutes** of unavailability. That's about how long it takes API Gateway to create the CloudFront Edge endpoint.
* Going from EDGE to REGIONAL results in about **30 seconds** of unavailability. That's about how long it takes API Gateway to create the Regional endpoint.

If you need to switch this and avoid downtime, you will need to do a manual blue-green deployment by creating a new environment with `JETS_ENV_EXTRA`.

## Routes Deployment

Jets does what is necessary to deploy route changes. Sometimes this requires replacing the Rest API entirely. Jets detects this and will create a brand new Rest API when needed. This is one of the reasons why a Custom Domain is recommended to be set up, so the endpoint url remains the same.  Generally, the route change detection works well. If you need to force the creation of a brand new Rest API, you can use `JETS_REPLACE_API=1 jets deploy`.

{% include prev_next.md %}