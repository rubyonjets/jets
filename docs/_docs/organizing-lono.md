---
title: Organizing Lono
---

## Breaking up app/definitions

If you have a lot of templates, the `app/definitions/base.rb` file can become unwieldy long.  You can break up the file and put them under the `app/definitions/base` folder. All files are loaded.

Though, you might find that using a balance of [shared variables]({% link _docs/shared-variables.md %}), [params]({% link _docs/params.md %}), and [native CloudFormation constructs]({% link _docs/tutorials/ec2/edit-native.md %}), and [layering]({% link _docs/layering.md %}) results in a short `app/definitions` files and you don't break up your `app/definitions` files in the first place.

<a id="prev" class="btn btn-basic" href="{% link _docs/nested-stacks.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/guard.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
