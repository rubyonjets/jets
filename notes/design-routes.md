# The issue is that both child stacks will create top-level landing resources.
# * Want to only create 1 landing resource.
# * Is this a better job for non-cloudformation?
# * Or do I make a custom Cloudformation resource that will gracefully handle this?
# * Ignore for now and handle later?

# * Another approach is define all the APIGatewayResource's in child stacks. If it goes over
# 60 resources (due to the 60 parameter limit) we automatically break up the nested child stacks.
