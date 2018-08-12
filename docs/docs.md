---
title: Overview
---

## What is Jets?

Jets is a Serverless Framework that allows you to create applications with Ruby. It includes everything required to build an application and deploy it to AWS Lambda.

It is key to understand AWS Lambda and API Gateway to understand Jets conceptually. Jets maps your code to Lambda functions and API Gateway resources.

* **AWS Lambda** is Functions as a Service. It allows you to upload and run functions without worrying about the underlying infrastructure.
* **API Gateway** is the routing layer for Lambda. It is used to route REST URL endpoints to Lambda functions.

## How It Works

You write code and Jets turns the code into Lambda functions and uploads them to AWS Lambda and API Gateway.

<a id="prev" class="btn btn-basic" href="{% link quick-start.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/controllers.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
