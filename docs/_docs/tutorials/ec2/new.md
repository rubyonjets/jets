---
title: "Tutorial EC2: lono new ec2"
---

The first command we'll walk through is the `lono new` command.  Here's the command with some output to focus on learning.

```
$ lono new ec2
=> Creating new project called ec2.
      create  ec2
      create  ec2/.gitignore
      create  ec2/Gemfile
      create  ec2/Guardfile
      create  ec2/README.md
      create  ec2/app/definitions/base.rb
      create  ec2/config/settings.yml
      create  ec2/welcome.txt
      create  ec2/app/helpers
      create  ec2/app/partials
      create  ec2/app/scripts
      create  ec2/app/templates
      create  ec2/app/user_data
      create  ec2/config/params
      create  ec2/config/variables
      create  ec2/output
=> Installing dependencies with: bundle install
=> Initialize git repo
================================================================
Congrats 🎉 You have successfully created a lono project.

Cd into your project and check things out:

  cd ec2

Add and edit templates for your project.  When you are ready to launch a CloudFormation stack run:

  lono cfn create STACK_NAME

You can also get started quickly by importing other CloudFormation templates into lono.  For example:

  lono import https://s3-us-west-2.amazonaws.com/cloudformation-templates-us-west-2/EC2InstanceWithSecurityGroupSample.template --name ec2

To re-generate your templates without launching a stack, you can run:

  lono generate

The generated CloudFormation templates are in the output/templates folder.
The generated stack parameters are in the output/params folder.  Here's the command with some output filtered to focus on learning.

More info: http://lono.cloud/
$
```

The new command does a few things:

1. Generates a starter lono project structure
2. Installs the project's dependencies
3. Initialized a git repository
4. Displays a welcome message and provides some guidance on what to do next

Let's focus on the project structure since this might be your first time looking at a lono.

<a id="prev" class="btn btn-basic" href="{% link _docs/tutorials/ec2/intro.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorials/ec2/project-structure.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
