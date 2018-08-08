---
title: "Tutorial: lono new autoscaling"
---

The first command we'll walk through is the `lono new` command.  Here's the command with some output to focus on learning.

```
$ lono new autoscaling
=> Creating new project called autoscaling.
      create  autoscaling
      create  autoscaling/.gitignore
      create  autoscaling/Gemfile
      create  autoscaling/Guardfile
      create  autoscaling/README.md
      create  autoscaling/app/definitions/base.rb
      create  autoscaling/config/settings.yml
      create  autoscaling/welcome.txt
      create  autoscaling/app/helpers
      create  autoscaling/app/partials
      create  autoscaling/app/scripts
      create  autoscaling/app/templates
      create  autoscaling/app/user_data
      create  autoscaling/config/params
      create  autoscaling/config/variables
      create  autoscaling/output
=> Installing dependencies with: bundle install
=> Initialize git repo
================================================================
Congrats 🎉 You have successfully created a lono project.

Cd into your project and check things out:

  cd autoscaling

Add and edit templates to your project.  When you are ready to launch a CloudFormation stack run:

  lono cfn create STACK_NAME

You can also get started quickly by importing other CloudFormration templates into lono.  For example:

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
2. Installs the projects dependencies
3. Initialized a git repository
4. Displays a welcome message and provides some guidance on what to do next

Let's focus on the project structure since this might be your first time looking at a lono.
