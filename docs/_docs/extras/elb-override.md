---
title: ELB Server Override Flag for jets server
---

## Background

While the goal of Jets is to create and deploy serverless services, there is often a need to run Jets in the server mode to debug your applications.
This may include hosting it on AWS and having it reachable through a load balancer such as an Application Load Balancer.

In the event you have a need to run it through an Elastic Load Balancer while running `jets server`, setting `JETS_ELB=1` will guarantee `jets server` behaviour even when behind an ELB. Context [#584](https://github.com/boltops-tools/jets/pull/584)
