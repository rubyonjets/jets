---
title: Layering Support
---

Lono supports a concept called layering.  Layering is how lono merges multiple files together to produce a final result.  This is useful for building multiple environments. For example, it is common to build separate production and development environment.  Most of the infrastructure is the same except for a few parts that require specific environment overrides.  Lono's layering ability makes this simple to do.

Going through a few examples of how lono performs layering will help make it clear the power of layering.

## Templates Layering

You configured your lono templates in the `app/definitions` folder. The starter project sets up a standard directory structure that layering is designed for.  Here's an example structure:

```sh
└── app
    └── definitions
        ├── base.rb
        ├── development.rb
        └── production.rb
```

Let's say these template definition files contain the following:

`app/definitions/base.rb`:

```ruby
template "example" do
  source "example"
end
```

`app/definitions/development.rb`:

```ruby
template "example" do
  source "example-dev"
end
```

`app/definitions/production.rb`:

```ruby
template "example" do
  source "example-prod"
end
```

Essentially with layering, when `lono generate` is called it will first evaluate `app/definitions/base.rb` and then evaluate the `LONO_ENV` specific definitions file.  By default `LONO_ENV=development`, so the evaluation order looks like this:

1. app/definitions/base.rb
2. app/definitions/base/* # all files in this folder
3. app/definitions/development.rb
4. app/definitions/development/* # all files this folder

This layering results in lono generating  different `output/templates.yml` with different template source views based on what `LONO_ENV` is set to. For example:

```sh
lono generate # LONO_ENV=development is default, so output/example.yml uses templates/example-dev.yml
LONO_ENV=production lono generate # output/example.yml uses templates/example-prod.yml
LONO_ENV=sandbox lono generate # output/example.yml uses templates/example.yml since there is no app/definitions/sandbox.rb yet
```

Notice, how for `LONO_ENV=sandbox` because there are no `app/definitions/sandbox.rb` the `app/definitions/base.rb` definition is used.

The layering ability of the templates definitions allows you to override which template view to use based on `LONO_ENV`. With this ability, you can have common infrastructure code in the base folder and override the specific environment parts.

## Variables Layering

{% include variable-layering.md %}

## Params Layering

Layering is also performed during param generation.  For example, given the following param structure:

```sh
config/params/
├── base
│   └── example.txt
└── production
    └── example.txt
```

When launching the example stack, lono will overlay the `LONO_ENV` specific param values on top of the base params values and use that result.  For example, given:

`param/base/example.txt`:

```sh
InstanceType=t2.small
```

`param/production/example.txt`:

```sh
InstanceType=t2.medium
```

Lono will use the `InstanceType=t2.small` parameter value when launching the stack with `LONO_ENV=production`.  Lono will use `InstanceType=t2.medium` for all other `LONO_ENV` values.  Example:

```sh
$ lono cfn create example # InstanceType=t2.small
$ LONO_ENV=production lono cfn create example # InstanceType=t2.medium
```

## Summary

Lono's layering concept provides you with the ability to define common infrastructure components and override them for specific environments when necessary. This helps you build multiple environments in an organized way. The layering processing happens for these lono components:

* [app/definitions]({% link _docs/app-definitions.md %}) - your template definitions and configurations.
* [config/variables]({% link _docs/shared-variables.md %}) - your shared variables available to all of your templates.
* [config/params]({% link _docs/params.md %}) - the runtime parameters you would like the stack to be launched with.

<a id="prev" class="btn btn-basic" href="{% link _docs/params.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/app-scripts.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
