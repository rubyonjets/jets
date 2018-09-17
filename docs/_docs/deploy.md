---
title: Deploy
---

Once you are ready to deploy your app to lambda, it's one command to do so:

    jets deploy

After deployment, you can test the Lambda functions with the AWS Lambda console or the CLI.

Lambda Functions:

![](/img/quick-start/demo-lambda-functions.png)

## Minimal Deploy IAM Policy

The IAM user you are using to run the `jets deploy` command needs a minimal set of IAM policies in order to deploy a Jets application. For more info, refer to the [Minimal Deploy IAM Policy]({% link _docs/minimal-deploy-iam.md %}) docs.

<a id="prev" class="btn btn-basic" href="{% link _docs/repl-console.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/jets-call.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
