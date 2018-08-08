---
title: Configure the Template
---

Let's configure the `@route53` variable in the template from the previous section. You configure this in the `app/definitions/base.rb` file by adding the following:

```ruby
template "single_instance" do
  source "instance"
end

template "instance_and_route53" do
  source "instance"
  variables(
    route53: true
  )
end
```

This tells lono to generate 2 CloudFormation templates and write them to the `output` folder using the ERB `templates/instance.yml` template.  The 2 output templates are going to be `output/single_instance.yml` and `output/instance_and_route53.yml`.  We've configured the `route53` variable to true for one of the templates and not for the other.

We will generate the templates in the next step.

<a id="prev" class="btn btn-basic" href="/docs/tutorial-template-build/">Back</a>
<a id="next" class="btn btn-primary" href="/docs/tutorial-template-generate/">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
