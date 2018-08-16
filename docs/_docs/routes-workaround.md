---
title: Routes Workaround
---

Underneath the hood, Jets uses CloudFormation to deploy Lambda functions and API Gateway resources. During an update operation, CloudFormation creates new resources, makes sure they are created successfully, and then deletes any old resources. CloudFormation does this so it to avoid a state where a resource was deleted first a new resource fails to create, completely logically.

For some resources,  the way CloudFormation updates can sometimes cause problems and a rollback. For example, if we replace an existing API Gateway route in one update operation this would cause a rollback. Because the route already exists, CloudFormation cannot create the new route.  We would have to delete the route in the `config/routes.rb` first in a separate deploy. Add then add the new desired route afterward. Removing a live route is unacceptable for many cases. However, this is where Jets and AWS Lambda power shines through. We simply create another [extra environment]({% link _docs/env-extra.md %}) and switch to it.

1. Create another environment
2. Test it to your heart's content
3. Switch the DNS over to the new stack
4. Delete the old environment

When we create new environments, we will not run into existing route conflicts because no routes exist. The application is brand new.

<a id="prev" class="btn btn-basic" href="{% link _docs/env-extra.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/surfacing-ruby-errors.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
