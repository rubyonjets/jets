---
title: jets console
reference: true
---

## Usage

    jets console

## Description

REPL console with Jets environment loaded.

## Example

    $ jets console
    >> Post.table_name
    => "posts"
    >> ActiveRecord::Base.connection.tables
    => ["schema_migrations", "ar_internal_metadata", "posts"]
    >> Jets.env
    => "development"
    >>

## Options

```
[--noop], [--no-noop]  
```

