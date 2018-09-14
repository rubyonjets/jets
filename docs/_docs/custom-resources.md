---
title: Custom Resources
---

You can create any custom AWS resources with Jets as a first-class citizen.  There are 2 types of custom resources you can create:

1. **Associated Custom Resources**: You define these resources above your methods or Lambda functions and they are meant to be tightly associated with the Lambda function.
2. **Shared Custom Resources**: You define these resources in the `app/shared/resources` folder and they are more standalone resources.  You reference these resources with the `lookup` method throught your code.

The custom resources are created as AWS CloudFormation resources and added to the generated templates as part of the build process. The next sections provide an introduction to how the core resource modeling behind Jets works and examples of the custom resources.

<a id="prev" class="btn btn-basic" href="{% link _docs/database-activerecord.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/core-resource.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
