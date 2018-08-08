---
title: lono new
reference: true
---

## Usage

    lono new NAME

## Description

Generates new lono project.

## Examples

    lono new infra # skeleton project with barebones structure
    TEMPLATE=ec2 lono new infra # creates a single server
    TEMPLATE=autoscaling lono new infra

By default, `lono new` generates a skeleton project. Use `TEMPLATE` to generate different starter projects. List of the [starter templates](https://github.com/tongueroo/lono/tree/master/lib/starter_projects).

## Example Output

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


## Options

```
[--force]                  # Bypass overwrite are you sure prompt for existing files.
[--bundle], [--no-bundle]  # Runs bundle install on the project
                           # Default: true
[--git], [--no-git]        # Git initialize the project
                           # Default: true
```
