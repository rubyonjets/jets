---
title: Generators
---

The Jets generators piggybacks off of the Rails generators. The generators have a lot of power and can save you time. You can use `jets generate -h` to list the generators:

    $ jets generate -h
    Jets:

        application_record
        controller
        helper
        job
        migration
        model
        resource
        scaffold
        scaffold_controller
        task

    ActiveRecord:

        active_record:application_record

To get more info on each generator provide the -h flag to each of them. Examples:

    jets generate controller -h
    jets generate job -h
    jets generate scaffold -h

Note: The help output is really the original rails generator help.

### Examples

Below is a list of cheatsheet-like examples for some of the generators.

### Controller

    jets generate controller CreditCards open debit credit close

### Helper

    jets generate helper CreditCard

### Job

    jets generate job hard

### Migration

    jets generate migration AddTitleBodyToPost title:string body:text published:boolean

### Model

    jets generate resource post title:string body:text published:boolean

### Scaffold

    jets generate scaffold post title:string body:text published:boolean

The scaffold generator also has an api mode.

    jets generate scaffold post title:string --api

### Scaffold Controller

    jets generate scaffold_controller CreditCard

### Task

    jets generate task feeds fetch erase add

