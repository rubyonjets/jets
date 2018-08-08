---
title: Create the Stack
---

We are now ready to create the stack.  Let's launch it!

```sh
lono cfn create ec2
```

You should see similar output.

```sh
$ lono cfn create ec2
Using template: output/templates/ec2.yml
Using parameters: config/params/development/ec2.txt
No detected app/scripts
Generating CloudFormation templates:
  output/templates/ec2.yml
  output/params/ec2.json
Parameters passed to cfn.create_stack:
---
stack_name: ec2
template_body: 'Hidden due to size... View at: output/templates/ec2.yml'
parameters:
- parameter_key: KeyName
  parameter_value: default
capabilities:
disable_rollback: false
Creating ec2 stack.
$
```

You can check on the status of the stack creation with the AWS Console.  It should look similar to this:

<img src="/img/tutorials/ec2/stack-created.png" alt="Stack Created" class="doc-photo">

Congratulations!  You have successfully created a CloudFormation stack with lono.

## lono generate

Let's take a closer look at the output of the `lono cfn create` command. Notice that it generated the template and parameter files from what was imported and wrote them to `output/templates` and `output/params`.  When working with templates, it is helpful to generate the templates and inspect them without launching a stack.  We can use the `lono generate` command to do that:

```
$ lono generate
Generating CloudFormation templates, parameters, and scripts
No detected app/scripts
Generating CloudFormation templates:
  output/templates/ec2.yml
Generating parameter files:
  output/params/ec2.json
$
```

You can then inspect `output/templates/ec2.yml` as well as `output/params/ec2.json` to make sure everything looks good before running `lono cfn create`.

## lono cfn create

Let's review the `lono cfn create` command in a little bit more detail.  We the following command to launch the stack:

```
lono cfn create ec2
```

Let's say we wanted a different set of parameters, like using a different keypair. We could create another params file and adjust it there.

```
cp config/params/base/ec2.txt config/params/base/ec2-different.txt
lono cfn create ec2 --template ec2 --param --ec2-different
```

Notice, that we needed to specify the `--template` and `--param` option in this case. We did not have to specify it before because lono uses a set of conventions. If no param option is provided, then the convention is for the param file to default to the name of the template option. The conventions are covered in detailed in [Conventions]({% link _docs/conventions.md %}) and makes for shorter commands when files are named consistently.


Next, we'll make some edits to the template and learn how to update the stack.

<a id="prev" class="btn btn-basic" href="{% link _docs/tutorials/ec2/import.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorials/ec2/cfn-update.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
