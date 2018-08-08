---
title: Nested Stack Support
---

## Uploading Templates to S3

By default, lono provides the generated template on the local file system when creating CloudFormation stacks. This is done to keep things simple and fast for the common use case of a single template.

However, if you are working with advanced nested CloudFormation templates that contain a parent stack and several child stacks, then the child templates must be uploaded and available in s3 for CloudFormation to work. Lono can upload the generated templates automatically with a simple configuration setting.  To enable s3 uploading post template generation:

```yaml
base:
  s3_folder: bucket/path/to/folder
```

That's all that is required to tell lono to upload the generated templates to s3. When `s3_folder` is set, lono will automatically upload templates to the `s3_folder` as part of the lifecycle `lono cfn` commands.

## Helper method for nested templates

Lono also provides helper methods to help work with nested CloudFormation templates.

Helper  | Description
------------- | -------------
`template_s3_path(name)`  | This is the s3 path where template gets uploaded to s3. This required for the `TemplateURL` property of an `AWS::CloudFormation::Stack` child stack resource.
`template_params(name)`  | This returns an Array of the parameter values. This is useful in a parent template if you are using nested templates. You can use this to grab the params values from child templates and specify the parameters within the parent template to other child templates.

### The template_s3_path helper

Instead of hard-coding the s3 bucket and path name in your parent stack you can use this helper to reference it from your `settings.yml` configuration. For example, if your s3_folder is configured in `settings.yml` like so:

```yaml
base:
  s3_folder: my-bucket/templates
```

And you use it in your `app/templates/parent.yml` like so:

```ruby
<%= template_s3_path("ChildTemplate") %>
```

This produces the url in your `output/templates/parent.yml`:

```ruby
https://s3.amazonaws.com/my-bucket/templates/production/ChildTemplate.yml
```

Note that the `LONO_ENV` is added to the final s3 path in case you are using the same s3 bucket for multiple environments.

### The template_params helper

Typically child templates in a nested stack setup use parameters specified in the parent stack template definition. The `template_params` helper allows you to grab the parameter values in the params files and inject them into the parent template. This allows you to launch the child template as separate stand-alone stacks using the runtime `params` values or as an embedded child stack using those same parameter values. Example:

`templates/parent.yml`:

```yaml
...
Resources:
  Network:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: <%= template_s3_path("network") %>
      Parameters:
      <% template_params("network").each do |key, value| %>
        <%= key %>: <%= value %>
      <% end %>
        CIDR: 10.11.0.0/16
...
```

`templates/child.yml`:

```yaml
...
Resources:
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock:
...
```

`params/base/child.txt`:

```sh
VpcName=main
DomainName=stack.local
```

Note you might want to put inline parameter values in the parent template at the bottom after the `template_params` loop, so it is clear what the final values parameters being passed into the child template are.

<a id="prev" class="btn btn-basic" href="{% link _docs/starter-templates.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/organizing-lono.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
