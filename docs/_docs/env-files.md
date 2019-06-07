---
title: Env Files
nav_order: 19
---

Jets loads environment variables from `.env` files. The naming convention for these files is `.env.<environment>`.

Let's say you have a Jets project that has the following dotenv files:

    .env
    .env.development
    .env.test
    .env.production

## Always Loaded

The `.env` file will always get loaded.

## Environment Specific Variables

The other `.env` files will be loaded based on value of the `JETS_ENV` environment variable in the machine you're deploying from. So:

* `JETS_ENV=development jets deploy` will use `.env.development`
* `JETS_ENV=test jets deploy` will use `.env.test`
* `JETS_ENV=production jets deploy` will use `.env.production`

You can set `JETS_ENV` to any value, depending on whatever you want to name your environment.

## Remote Only Variables

If you add ".remote" to the end of the filename, Jets will only load the values to the deployed Lambda environment. This can be useful if you need a local and remote version of the same environment. For example, you may want both a local and remote dev environment, and have the remote version using AWS RDS.

To use the remote version within the `jets console`, you can use the `JETS_ENV_REMOTE=1` env variable. Example:

    JETS_ENV=development JETS_ENV_REMOTE=1 jets console

{% include prev_next.md %}

## Referencing the AWS Systems Manager (SSM) Parameter Store

A common practice when using AWS is to store configuration and credentials in the SSM parameter store. You can reference SSM Parameters as the source of your variables with the `ssm:param-name` syntax. `param-name` can be either a relative or absolute path. Absolute paths are prefixed with a leading `/`. Relative parameters will automatically be prefixed with the conventional `/<app-name>/<jets-env>/`. For example:

    RELATIVE_DATABASE_URL=ssm:database-url # references /<app-name>/<jets-env>/database-url
    ABSOLUTE_DATABASE_URL=ssm:/path/to/database-url # references /path/to/database-url

The SSM parameters are fetched and interpolated into your environment at build time so make sure to re-deploy your app after making changes to your SSM parameters to ensure they are picked up correctly.
