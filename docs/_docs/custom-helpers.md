---
title: Custom Helpers
---

It is useful be able to call methods in your template views that are not built into lono. Lono allows you to add custom helpers for this case.  The custom helpers are first class citizens and have access to the same context and variables as [built-in lono helpers]({% link _docs/builtin-helpers.md %}).

## How to Add Custom Helper Methods

To add custom helpers methods, create a file that ends with `_helper.rb` in the `app/helpers` folder of your project. Declare a module in that file naming the module the same as the filename except in camel case form.  Then define your helper methods in the module.  For example:

`helpers/my_custom_helper.rb:`

```ruby
module MyCustomHelper
  def shared_partial(name, options={}, indent=0)
    partial_name = "shared/#{name}.yml.erb"
    if partial_exist?(partial_name) # partial_exist? is built-in lono helper
      result << partial(partial_name, {}, indent: indent)
      result.join("\n")
    end
  end
end
```

The `shared_partial` method is now available in your template views.  Notice how in the example `shared_partial` calls built-in lono helper methods like `partial_exist?` with no problem. All lono built-in helper methods are available in your custom helper methods.  Variables are also available to be used in your custom helper methods.  Example:

`app/definitions/base.rb`:

```ruby
template "example" do
  variables(
    disk_size: "80GB"
  )
end
```

`helpers/disk_space_helper.rb`:

```ruby
module DiskSpaceHelper
  def size_in_bytes
    return unless @disk_size
    md = @disk_size.match(/(\d+)(\s+)$/)
    if md
      _, amount, units = md.to_a
      amount = amount.to_i
    end
    case units
    when "GB"
      amount * 1024 * 1024
    when "MB"
      amount * 1024
    else # assume in bytes already
      size.to_i
    end
  end
end
```

Notice how `@disk_size` is used in the `size_in_bytes` helper method.

<a id="prev" class="btn btn-basic" href="{% link _docs/builtin-helpers.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/conventions.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
