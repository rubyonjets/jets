---
title: Env Files
nav_order: 18
---

Jets loads environment variables from `.env` files. The naming convention for these files is `.env.<environment>` .

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

If you add ".remote" to the end of the filename, Jets will only load the values to the deployed Lambda environment. This can be useful if you need a local and remote version of the same environment. For example, you may want both a local and remote dev environment, and have the remote version use AWS RDS.

To use the remote version within the `jets console`, you can use the `JETS_ENV_REMOTE=1` env variable. Example:

    JETS_ENV=development JETS_ENV_REMOTE=1 jets console

{% include prev_next.md %}