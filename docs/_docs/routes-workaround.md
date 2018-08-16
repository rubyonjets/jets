---
title: Routes Workaround
---

Underneath the hood, Jets makes use of CloudFormation to deploy Lambda functions and API Gateway resources. During an update operation, CloudFormation creates new resources and make sure they are created successfully before deleting any old resources. This makes sense because we do not want to ever be in the state where one of our resources was deleted first and then CloudFormation fails to create the new resource.

The way CloudFormation updates can sometimes cause problems when updating existing routes since routes must have specific paths. For example, if we update existing homepage route this would cause a CloudFormation stack rollback. This is because the homepage route already exists.  We would have to delete the route in the `config/routes.rb` first in a separate deploy. Add the new desired route and then deploy again. This is likely unacceptable, so the current suggested workaround is to take advantage of the [Jets Env Extra]({% link _docs/env-extra.md %}) ability.

1. Create another environment
2. Test it to your hearts content
3. Switch the DNS over to the new stack
4. Delete the old environment

When we create new environments, we will not run into existing route conflicts because zero routes exist. The application is brand new.

<a id="prev" class="btn btn-basic" href="{% link _docs/env-extra.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/surfacing-ruby-errors.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
