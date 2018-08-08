Lono is a CloudFormation framework tool that helps you manage your templates.  Lono handles the entire CloudFormation lifecycle. It starts with helping you develop your templates and helps you all the way to the infrastructure provisioning step.

{:.overview-stages}
1. The first stage of lono is you crafting and writing the CloudFormation templates. Lono enables you to write your CloudFormation templates in an ERB templating language and provides useful helper methods. Once you are ready, then you can generate the templates with `lono generate`.
2. You then specify the desired parameters use for CloudFormation template. You do this with simple env-like param files. The format is easy on the eyes.
3.  In the end, lono puts it all together and launches the stack for you. It takes what is normally a manual multi-step process and simplifies it down to a single command: `lono cfn create`.

Here is a diagram that describes how lono works.

<img src="/img/tutorial/lono-flowchart.png" alt="Stack Created" class="doc-photo lono-flowchart">

## Lono Features

* Lono generates standard CloudFormation templates from ERB templates, providing you with the expressive power of the ERB's templating engine.
* Lono allows you to write your CloudFormation parameters files in a simple env-like file.
* Lono provides a simple command line interface to create, update, delete and preview CloudFormation changes.
* Lono supports layering which allows you to build multiple environments like development and production quickly.
