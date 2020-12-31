---
title: Custom Resources
---

You can create any custom AWS resources with Jets as a first-class citizen.  There are 2 types of custom resources:

1. **Associated Custom Resources**: You define these resources above your methods, and they are meant to be associated with the Lambda function below it.
2. **Shared Custom Resources**: You define these resources in the `app/shared/resources` folder, and they are standalone resources.

The custom resources are added to the generated AWS CloudFormation templates as part of the build process. The next sections provide an introduction to the core resource modeling behind Jets and examples of the custom resources.

