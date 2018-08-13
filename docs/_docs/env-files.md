---
title: Env Files
---

Jets can load environment variables from `.env` files. There can be few different dotenv files that get loaded and combined. An example best explains how dotenv files work.

Say you have a Jets project that has the following dotenv files:

    .env
    .env.development
    .env.development.deploy
    .env.test
    .env.production

## Always loaded

The `.env` file will always get loaded.

## Environment specific variables

The second word is the `JETS_ENV` value. So:

* `JETS_ENV=development` corresponds to `.env.development`
* `JETS_ENV=test` corresponds to `.env.test`
* `JETS_ENV=production` corresponds to `.env.production`

These files only get loaded for the configured valued of `JETS_ENV`. This allows you to use different environment variables for development vs production environments.

## Deploy specific variables

The last example file is `.env.development.deploy`.  The values from this file only get loaded for the deployed remote Lambda Functions. It can be useful if you need different values on the lambda function and would like to keep the same `JETS_ENV`.

<a id="prev" class="btn btn-basic" href="{% link _docs/prewarming.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/config-rules.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
