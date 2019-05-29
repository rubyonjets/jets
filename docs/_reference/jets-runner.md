---
title: jets runner
reference: true
---

## Usage

    jets runner

## Description

Run Ruby code in the context of Jets app non-interactively.

## Examples

    $ jets runner 'puts "hi"'
    hi
    $ jets runner 'puts Jets.env'
    development

Using a script in a file.  Let's say you have a script:

script.rb:

```ruby
puts "hello world: #{Jets.env}"
```

    $ jets runner file://script.rb
    hello world: development

## Options

```
[--noop], [--no-noop]  
```

