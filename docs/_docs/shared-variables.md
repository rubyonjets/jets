---
title: Shared Variables
---

## Template Shared Variables

Template shared variables are available to all template definition config blocks, template views, and params.  These variables are defined in the `config/variables` folder.  The variables files are merely ruby scripts where instance variables (variables with an @ sign in front) are made available.

Here's an example:

`config/variables/base.rb`:

```ruby
@ami = "ami-base"
```

The `@ami` variable is now available to all of your templates.  Effective use of shared variables can dramatically shorten down your template definitions.

## Layering Support

Variables also support layering. {% include variable-layering.md %}

More details on layering is covered in [Layering Support]({% link _docs/layering.md %}).

<a id="prev" class="btn btn-basic" href="{% link _docs/app-definitions.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/params.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
