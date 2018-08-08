---
title: Lono Current
---

Sets current values so you do not have to provide the options repeatedly.  This shortens the commands.

{% include current-options.md %}

## Examples

Create a demo stack and set it as the current stack name.

    lono cfn create demo

The normal update and preview commands are:

    lono cfn update demo
    lono cfn preview demo

Shortened commands:

    lono cfn current --name demo
    lono cfn update
    lono cfn delete
    lono cfn preview
    lono cfn diff
    lono cfn download
    lono cfn status

The stack name is not longer required because it is set as the current name.

## Suffix Example

Random suffixes can help streamlined your development workflow.

    lono cfn current --suffix random
    lono cfn create demo
    lono cfn update demo-abc # generated random suffix was abc
    lono cfn current --name demo-abc
    lono cfn update
    lono cfn update # update again

In this way, you can create multiple stacks continuously and random suffixes will be appended to the stack name. Then set the current stack name to the one are focused on updating and developing.

## Remove all settings

To remove all current settings.

    $ lono cfn current --rm
    Current settings have been removed. Removed .lono/current

## Considerations

* The current name setting does not apply to the `lono create` method. The create method requires that you explicitly specify the name: `lono create STACK_NAME`. The create command uses the `--suffix` option only.
* The current name setting applies on commands that refer to existing stacks like update, delete, preview, diff and download.

<a id="prev" class="btn btn-basic" href="{% link _docs/settings.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/lono-suffix.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
