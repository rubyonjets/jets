---
title: Conventions
---

Lono follows a set of naming conventions to encourage best practices in a naming scheme. This also dramatically allows lono commands to be shorter and hopefully more memorable.

## CLI Template Name Convention

These conventions are followed by all the `lono cfn` commands: `create`, `update`, `preview`, etc.

By convention, the template name is the same as the stack name.  In turn, the param name will default to the template name.

* stack - This is a required parameter and is the CLI first parameter.
* template - By convention matches the stack name but can be overridden with `--template`.
* param - By convention matches the template name but can be overridden with `--param`.

For example, these two commands are the same:

Long form:

```
$ lono cfn create mystack --template mystack --param --mystack
```

Short form:

```
$ lono cfn create mystack
```


Both template and param conventions can be overridden.  Here are examples of overriding the template and param naming conventions.

```
$ lono cfn create mystack --template different1
```

The template that will be use is `output/templates/different1.json` and the parameters that will use `output/params/different1.json`.

```
$ lono cfn create mystack --param different2
```

The template that will be used is `output/templates/mystack.json` and the parameters that will use `output/params/different2.json`.

```
$ lono cfn create mystack --template different3 --param different4
```

The template that will be used is `output/templates/different3.json` and the parameters that will use `output/params/different4.json`.

## Template Output and Source Name Convention

By convention, the template source name defaults to output name specified. Often, this means you do not have to specify the source.  For example:

```ruby
template "example" do
  source "example"
end
```

Is equivalent to:

```ruby
template "example" do
end
```

Furthermore, since the `do...end` block is empty at this point it can be removed entirely:

```ruby
template "example"
```

## Format and Extension Convention

For templates, lono assumes a format extension of `.yml`.  The format is then tacked onto the output filenames automatically when writing the final generated templates. For example:

```ruby
template "example" do
  source "example"
end
```

A `templates/example.yml` file results in creating `output/templates/example.yml` when lono generate is ran.

The extension for filenames used in partial helper is auto-detected. For example, given a partial in `templates/partials/elb.yml` a call to `partial("elb")` would automatically know to load elb.yml. As another example, given a partial in `templates/partials/script.sh`, then `partial("script")` would automatically load `script.sh`.

In the case where the extension is ambiguous, you must specify the extension explicitly. For example, given:

```sh
templates/partial/volume.sh
templates/partial/volume.yml
```

In this case, a call to `partial("volume")` is ambiguous. Which one should lono render: volume.sh or volume.yml? In this case, you must specify the extension in the helper call: `partial("volume.yml")` to remove the ambiguity.

<a id="prev" class="btn btn-basic" href="{% link _docs/custom-helpers.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/settings.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
