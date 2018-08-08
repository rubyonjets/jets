---
title: Params
---

## Param Files

With lono, you can specify CloudFormation parameters with simple formatted `key=value` env-like file instead of the CloudFormation's normal JSON format. Let's take a closer look at the params file we've been using so far. The `config/params/base/ec2.txt` file looks like this:

```
KeyName=default
#InstanceType=        # optional
#SSHLocation=         # optional
```

When lono goes through the generation phase, it translates the param files from the simple env-like format to the CloudFormation JSON format and writes it to `output/params/ec2.json`:

```json
[
  {
    "ParameterKey": "KeyName",
    "ParameterValue": "default"
  }
]
```

The env-like format allows you to add comments to the params files and are more simple to read.

## Layering support

Notice that the file in the config folder includes a `base` in its path, but the file in the output folder does not. This is because params files are layered together to produce a final result.  This layering is merely the merging of multiple params files together.

We'll demonstrate layering by adding few changes. For the existing param file `config/params/base/ec2.txt` we'll update it to:

```
KeyName=default
InstanceType=t2.micro
```

Now we'll create another file: `config/params/production/ec2.txt`:

```
InstanceType=t2.medium
```

Now we'll generate the templates two times with a different `LONO_ENV` environment variable each time:

```
lono generate # LONO_ENV=development by default
```

Let's take a look at `output/params/ec2.json`:

```json
[
  {
    "ParameterKey": "KeyName",
    "ParameterValue": "default"
  },
  {
    "ParameterKey": "InstanceType",
    "ParameterValue": "t2.micro"
  }
]
```

Generate the params files again with a different `LONO_ENV=production`:

```
LONO_ENV=production lono generate
```

It produces a different `output/params/ec2.json` result:

```json
[
  {
    "ParameterKey": "KeyName",
    "ParameterValue": "default"
  },
  {
    "ParameterKey": "InstanceType",
    "ParameterValue": "t2.medium"
  }
]
```

The `base` param files are special, and they always get merged. The other param files associated with `LONO_ENV` are merged for its specific environment.

Layering allows us to use some different parameter values for different environments.  The layering concept applies to other components as well and is covered in more detailed in the [Layering docs]({% link _docs/layering.md %}).

## Shared Variables Support

Param files have access to shared variables, which also support layering.  Sometimes, by using shared variables, you can use simplify your param files.  Let's go through another example.  We'll add some shared variables files.

We'll create a `config/variables/base.rb` which has:

```ruby
@instance_type = "t2.micro"
```

We'll create a `config/variables/production.rb` which has:

```
@instance_type = "t2.small"
```

Now we'll make changes to the params files to use the variables `config/params/base/ec2.txt`:

```
KeyName=default
InstanceType=<%= @instance_type %>
```

And we'll remove the no longer needed `config/params/production/ec2.txt`:

```
rm -f config/params/production/ec2.txt
rmdir config/params/production
```

When you generate the params again, we get the same result as before. A `lono generate` produces at `output/params/ec2.json` result a InstanceType of `t2.micro` and a `LONO_ENV=production lono generate` will have a InstanceType of `t2.small`.

## Helper Support

Param files also have access to your own [custom helpers]({% link _docs/custom-helpers.md %}).  This allows you to add logic at the run-time phase.  You can pretty much add any logic you need.

<a id="prev" class="btn btn-basic" href="">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorials/ec2/cfn-create.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
