---
title: Custom Domain
---

Jets can create and associate a route53 custom domain with the API Gateway endpoint.  Jets manages the vanity route53 endpoint that points to the API Gateway endpoint.  It adjusts the endpoint transparently without you having to update your endpoint if Jets determines that a new API Gateway Rest API needs to be created. The route53 record is also updated. Here's a table with some example values to explain:

Vanity Endpoint | API Gateway Endpoint | Jets Env Extra
--- | --- | ---
dev-demo.coolapp.com | a02oy4fs56.execute-api.us-west-2.amazonaws.com | (not set)
dev-demo-2.coolapp.com | xyzoabc123.execute-api.us-west-2.amazonaws.com | 2

Here's a diagram also:

![](/img/docs/routing/jets-vanity-endpoint.png)

## Vanity Endpoint

NOTE: If you have already previously set up an API Custom Domain, when Jets tries to add the Custom Domain it will fail. This is because the Custom Domain already exists, CloudFormation sees this, and will not destructively delete existing resources managed outside of its purview. Both the Custom Domain and the Route53 record associated with that domain must be deleted before running `jets deploy`. This will occur downtime until the `jets deploy` completes. Fortunately, this only needs to be done once and after that Jets manages the vanity endpoint.  It is recommended that you set up the Custom Domain as early as possible so you do not run into this down the road.

To create a vanity endpoint edit the `config/application.rb` and edit `domain.cert_arn` and `domain.hosted_zone_name`:

```ruby
Jets.application.configure do
  config.domain.cert_arn = "arn:aws:acm:us-west-2:112233445577:certificate/8d8919ce-a710-4050-976b-b33da991e7e8" # String
  config.domain.hosted_zone_name = "coolapp.com" # String
  # config.domain.name = "#{Jets.project_namespace}.coolapp.com" # Default is the example convention

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

Jets does what is necessary to deploy route changes. Sometimes this requires replacing the Rest API entirely. Jets detects this and will create a brand new Rest API when needed. Jets does this because CloudFormation is unable to deploy certain API Gateway changes cleanly when:

* The `config.api.binary_media_types` has changed.
* A route definition with the same path and method to has been updated. IE: `get "/signin", to: "/users#signin"` to `get "/signin", to: "/signups#signin"`
* A route variable at the same parent path has changed. IE: `get "/posts/:id", to: "/posts/#show"` to `get "/posts/:post_id", to: "/posts/#show"`
* Routes have moved to different cloudformation stacks or "pages". With large apps that have 100+ routes, Jets must generate multiple stacks in order to stay under the [CloudFormation resource limits](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cloudformation-limits.html). Reordering routes with these large apps can trigger a change.

Important: When a new API Gateway is deployed, the endpoint will change. This is one of the reasons why a Custom Domain is recommended to be set up, so the endpoint url remains the same.  Generally, the route change detection works well. If you need to force the creation of a brand new Rest API, you can use `JETS_REPLACE_API=1 jets deploy`.

## HostedZoneId

You can also specify a `hosted_zone_id` instead of `hosted_zone_name`.

```ruby
Jets.application.configure do
  config.domain.cert_arn = "arn:aws:acm:us-west-2:112233445577:certificate/8d8919ce-a710-4050-976b-b33da991e7e8" # String
  config.domain.hosted_zone_name = "coolapp.com" # String
  config.domain.hosted_zone_id = "/hostedzone/Z2E57RZEXAMPLE"
end
```

Note, you should still specify the `hosted_zone_name` because it is conventionally used for the API Gateway Custom Domain name.

## Disable Route53

If `config.domain.hosted_zone_name` is set, then `config.domain.route53=true` will be the default behavior. It is useful to turn off the Jets managed route53 record if you would like to manage the DNS yourself.  Though there may be little point as the DNS must always match the API Custom Domain Name.

```ruby
Jets.application.configure do
  # ...
  config.domain.route53 = false # disable route53 from being managed by jets.
```

## Route53 Apex Domain

Jets creates a CNAME route53 record by default. Jets can also create zone apex records or naked domain names. Example:

```ruby
Jets.application.configure do
  config.domain.cert_arn = "arn:aws:acm:us-west-2:112233445577:certificate/8d8919ce-a710-4050-976b-b33da991e7e8" # String
  config.domain.hosted_zone_name = "coolapp.com" # String
  config.domain.name = "coolapp.com"
  config.domain.apex = true # # apex or naked domain. Use AliasTarget with an A record instead of a CNAME
end
```

Though apex records are supported, it is recommended to put CloudFront of the API Gateway Custom Domain instead.

## CloudFront Recommendation

For the most control, it is recommended to create a CloudFront distribution **outside** of Jets. Then put CloudFront in front of the API Gateway Custom Domain.  Example:

![](/img/docs/routing/jets-vanity-endpoint-cloudfront.png)

This provides you full manual control over the DNS. You can deploy additional [extra environments]({% link _docs/env-extra.md %}) and update which Jets environment CloudFront points to. This type of blue-green deployment can be useful for large feature rollouts. Using CloudFront will also allow you to do things like redirect http to https. A notable drawback is that CloudFront changes can take 5m-20m to deploy.

## CloudFront Host

When [CloudFront is configured with API Gateway](https://aws.amazon.com/premiumsupport/knowledge-center/api-gateway-cloudfront-distribution/), the Host header cannot is not passed to API Gateway. So the `request.host` your Jets app sees is the API Gateway Custom Domain. This will cause issues for methods like `redirect_to`.  To set the host you can:

1. Set the `config.app.domain` option.
2. Configure the CloudFront distribution with a Host Header `origin`.

Configuring either of these will set the host the app with "see".  The `config.app.domain` option takes the highest precedence.

## Multiple Custom Domain Base Paths

You can configure the base path in the custom domain by adding the base_path parameter . Example:

```ruby
Jets.application.configure do
  config.domain.cert_arn = "arn:aws:acm:us-west-2:112233445577:certificate/8d8919ce-a710-4050-976b-b33da991e7e8" # String
  config.domain.hosted_zone_name = "coolapp.com" # String
  config.domain.name = "coolapp.com"
  config.domain.base_path = "accounts"
end
```

If then deploy another app with the same `domain.name` but a different `domain.base_path = "api"`, then the mapping works like this:

    coolapp.com/accounts => root of jets app 1
    coolapp.com/api      => root of jets app 2
