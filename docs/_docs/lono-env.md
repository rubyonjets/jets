---
title: LONO_ENV
---

Lono's behavior is controlled by the `LONO_ENV` environment variable.  For example, the `LONO_ENV` variable is used to layer different lono files together to make it easy to define multiple environments like production and development.  This is covered thoroughly in the [Layering docs]({% link _docs/layering.md %}).  `LONO_ENV` defaults to `development` when not set.

## Setting LONO_ENV

The `LONO_ENV` can be set in several ways:

1. At the CLI command invocation - This takes the highest precedence.
2. Exported as an environment variable to your shell - This takes the second highest precedence.
3. As a `aws_profiles` value in your lono `settings.yml` file - This takes the lowest precedence.

## At the CLI Command

```sh
LONO_ENV=production lono generate
```

## As an environment variable

```sh
export LONO_ENV=production
lono generate
```

If you do not want to remember to type `LONO_ENV=production`, you can set it in your `~/.profile`.

## Settings: aws_profiles

The most interesting way to set `LONO_ENV` is with `aws_profiles` in `settings.yml`.  Let's say you have a `settings.yml` with the following:

```yaml
development:
  aws_profiles:
    - dev_profile1
    - dev_profile2
production:
  aws_profiles:
    - prod_profile
```

In this case, when you set `AWS_PROFILE` to switch AWS profiles, lono picks this up and maps `aws_profiles` to the containing `LONO_ENV` config.  Example:

```sh
AWS_PROFILE=dev_profile1 => LONO_ENV=development
AWS_PROFILE=dev_profile2 => LONO_ENV=development
AWS_PROFILE=prod_profile => LONO_ENV=production
AWS_PROFILE=whatever => LONO_ENV=development # default since whatever is not found
```

This prevents you from switching `AWS_PROFILE`, forgetting to also switch `LONO_ENV`, and accidentally deploying to production vs. development. More info on settings is available at the [Settings docs]({% link _docs/settings.md %}).

<a id="prev" class="btn btn-basic" href="{% link _docs/directory-structure.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/import-template.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
