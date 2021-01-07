---
title: Jets New Modes
---

The `jets new` command has 3 different modes: html, api, and job. Use the `--mode` option to specify one of them.  The modes allow you to generate different starter Jets projects for different needs.

## Examples

    jets new demo --mode html # default
    jets new api --mode api
    jets new cron --mode job

## Mode Summary

Here's a table that describes the different modes. It briefly covers when it may make sense to use one over the other. 

Mode | Description
--- | ---
html | The html mode generates a starter app useful for html web applications. This mode includes webpacker and assets. This article may be of use [Jets CRUD Introduction](https://blog.boltops.com/2018/09/07/jets-tutorial-crud-app-introduction-part-1) if you're looking at this mode.
api | The api mode is useful for building APIs. This mode does not include webpacker or assets.  You may be interested in this article: [Build an API with the Jets](https://blog.boltops.com/2019/01/13/build-an-api-service-with-jets-ruby-serverless-framework) if you're looking at this mode.
job | The job mode creates a very lightweight project. It is useful when you only need to run just a few Lambda function. It's a perfect mode if you want something like a [Serverless Cron Job with Jets](https://blog.boltops.com/2019/01/03/serverless-ruby-cron-jobs-with-jets-route53-backup)

## Structure

With **HTML** mode, the fullest structure is generated.

```
.
├── app
│   ├── controllers
│   ├── helpers
│   ├── javascript
│   ├── jobs
│   ├── models
│   └── views
├── bin
├── config
├── db
├── public
└── spec
```

With **API** mode, a lighter structure is generated.

```
.
├── app
│   ├── controllers
│   ├── helpers
│   ├── jobs
│   └── models
├── config
├── db
├── public
└── spec
```

With **Job** mode, a super lightweight structure is generated.  Job mode also defaults to no database.


```
.
├── app
│   └── jobs
└── config
```


## No Database Option

A notable option is the `--no-database` option.  If you have an app that does not require a database, it is useful to have `jets new` generate a skeleton app without a database configured.  Here's an example with api mode and no database:

    jets new api --mode api --no-database
    
Refer to the CLI reference [jets new](http://rubyonjets.com/reference/jets-new/) for more info.

