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