---
title: "Tutorial EC2: Edit Template"
---

The imported EC2 template we've been working with contains an EC2 instance and security group.  Next, we show you how you can use lono to manage your templates.

## Lono Phases Review

First, let's review the lono phases:

<img src="/img/tutorial/lono-flowchart.png" alt="Stack Created" class="doc-photo lono-flowchart">

Lono introduces a Compile phase where it takes the `app/templates` files, uses ERB variables, and produces different templates in the `output/templates` folder.  With Lono, there are a few possible approaches to editing the templates:

1. Compiling Different Templates with Lono during the first generation phase
2. Using Native CloudFormation Logical Constructs during the second run-time phase

## Add EIP Address to Instance

As an example, let's add an EIP address to the template and associate it with the EC2 instance.  Let's say that sometimes an EIP address is desirable and sometimes it is not.  We'll first show you how to achieve this with the compiling different templates approach.

## Compiling Different Templates Approach

Compiling different templates is pretty straightforward with lono templates.  The source code for these changes is in the `eip` branch of [lono-tutorial-ec2](https://github.com/tongueroo/lono-tutorial-ec2/blob/eip/app/templates/ec2.yml).  Let's take a look at the relevant [changes](https://github.com/tongueroo/lono-tutorial-ec2/compare/eip).

How we changed `app/definitions/base.rb`:

Before:

```ruby
template "ec2"
```

After:

```ruby
template "ec2" do
  source "ec2"
  variables(eip: false)
end
template "eip" do
  source "ec2"
  variables(eip: true)
end
```

The new code tells lono to generate 2 templates at `output/templates/ec2.yml` and `output/templates/eip.yml`. Both templates use the same source template `app/templates/ec2.yml`. However, each one has a different value for the `eip` variable.  The `eip` variable is available in the `app/templates` as the `@eip` instance variable.

We modify the source template `app/templates/ec2.yml` and add
`<% if @eip %>` checks where we want to include EIP related components. Here's a portion of the template to demonstrate:

```
...
  InstanceSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Enable SSH access via port 22
      SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: '22'
        ToPort: '22'
        CidrIp:
          Ref: SSHLocation
<% if @eip %>
  IPAddress:
    Type: AWS::EC2::EIP
  IPAssoc:
    Type: AWS::EC2::EIPAssociation
    Properties:
      InstanceId:
        Ref: EC2Instance
      EIP:
        Ref: IPAddress
<% end %>
Outputs:
  InstanceId:
    Description: InstanceId of the newly created EC2 instance
    Value:
      Ref: EC2Instance
...
```

Here's the full template code [ec2.yml code](https://github.com/tongueroo/lono-tutorial-ec2/blob/eip/app/templates/ec2.yml).  You can also see the exact adjustments with the [compare view](https://github.com/tongueroo/lono-tutorial-ec2/compare/eip).

## ERB vs CloudFormation Template

With ERB, we are not limited to just if statements.  We can use loops, variables, expressions, etc.  Here is a good post covering ERB templates [An Introduction to ERB Templating](http://www.stuartellis.name/articles/erb/). Additionally, we have access to lono [built-in helpers]({% link _docs/builtin-helpers.md %}) and [shared variables]({% link _docs/shared-variables.md %}).  We can also define our own [custom helpers]({% link _docs/custom-helpers.md %}) if needed.

### Lono Generate

It is helpful to generate the templates and verify that the files in `output/templates` look like what we expect before launching.

```
$ lono generate
Generating CloudFormation templates, parameters, and scripts
No detected app/scripts
Generating CloudFormation templates:
  output/templates/ec2.yml
  output/templates/eip.yml
Generating parameter files:
  output/params/ec2.json
$
```

We can also use `lono summary` to see that the resources are different. Here's the output of `lono summary` with the parameters info filtered out:

```
$ lono summary ec2
Resources:
  1 AWS::EC2::Instance
  1 AWS::EC2::SecurityGroup
  2 Total
$ lono summary eip
Resources:
  1 AWS::EC2::Instance
  1 AWS::EC2::SecurityGroup
  1 AWS::EC2::EIP
  1 AWS::EC2::EIPAssociation
  4 Total
$
```

We can see that `ec2` has 2 resources and `eip` has 4 resources; what we expect.

Another way we can compare the 2 generated templates is by diff-ing them.

```diff
$ diff output/templates/ec2.yml output/templates/eip.yml
394a395,403
>   IPAddress:
>     Type: AWS::EC2::EIP
>   IPAssoc:
>     Type: AWS::EC2::EIPAssociation
>     Properties:
>       InstanceId:
>         Ref: EC2Instance
>       EIP:
>         Ref: IPAddress
406,407c415,416
<   PublicDNS:
<     Description: Public DNSName of the newly created EC2 instance
---
>   InstanceIPAddress:
>     Description: IP address of the newly created EC2 instance
409,417c418
<       Fn::GetAtt:
<       - EC2Instance
<       - PublicDnsName
<   PublicIP:
<     Description: Public IP address of the newly created EC2 instance
<     Value:
<       Fn::GetAtt:
<       - EC2Instance
<       - PublicIp
---
>       Ref: IPAddress
```

### Launch Stacks

When things look good, launch both stacks:

```
lono cfn create ec2
lono cfn create eip --param ec2
```

You should see the new stacks now. It should look something like this:

<img src="/img/tutorials/ec2/both-stacks.png" alt="Stack Created" class="doc-photo lono-flowchart">

Notice how for the second command needed to specify the `--param eip` option.  We're using the same params for both stacks.  The first command did not require us to specify the param file because lono conventionally defaults the param name to the template name. The conventions are covered in detailed in [Conventions]({% link _docs/conventions.md %}).

If you need to, use `lono cfn update` that you learned in the last section until you get the template working as you expect.

```
lono cfn update ec2
lono cfn update eip --param ec2
```

Move on once things look good and you're ready to move onto the next step.

### Clean Up

Let's do a little cleanup and introduce the `lono cfn delete` command.  The delete commands will prompt you with a "Are you sure?" prompt.  Delete some of the stacks before continuing with:

```
lono cfn delete ec2
lono cfn delete eip
```

### Congrats
Congratulations 🎉 You have successfully added conditional logic to CloudFormation templates that decide whether or not to create an EIP.

<a id="prev" class="btn btn-basic" href="{% link _docs/tutorials/ec2/cfn-update.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorials/ec2/edit-native.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
