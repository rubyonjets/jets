---
title: Blue-Green Deployment
---

## Background

Underneath the hood, Jets uses CloudFormation to deploy Lambda functions and API Gateway resources. During an update operation, CloudFormation creates new resources, makes sure they are first created successfully, and then deletes any old resources. CloudFormation does this so to avoid deleting the existing resource and putting us stuck in a terrible state. It is completely logical.

## Automated Blue-Green Deployment

For some resources, the way CloudFormation updates can sometimes fail and rollback. Notably, changing API Gateway routes can cause a rollback.  Jets checks the routes and replaces the API Gateway Rest API entirely when needed to avoid a rollback.  Jets essentially performs an automated blue-green of API Gateway in this case.  This results in changing the API Gateway DNS endpoint.  At the end of `jets deploy` the updated API Gateway endpoint is provided.

If you have configured a [Custom Domain]({% link _docs/routing/custom-domain.md %}) then this custom domain automatically gets updated as part of the automated blue-green deployment.

## Manual Blue-Green Deployment

For the most part, Jets auto blue-green deployments suffice.  Manual blue-green deployments are sometimes required though.  For example, [upgrading]({% link _docs/extras/upgrading.md %}) between different versions of Jets can require a blue-green deployment.

This is where Jets and AWS Lambda power shines. We simply create another [extra environment]({% link _docs/env-extra.md %}) and switch to it to do a manual blue-green deployment.  Here are the steps:

1. Create another environment by deploying with `JETS_ENV_EXTRA`.
2. Test it to your heart's content
3. Switch the API Gateway Custom Domain over to the new stack
4. Delete the old environment

When we create new environments there will be no CloudFormation update issues because the application is entirely brand new.

