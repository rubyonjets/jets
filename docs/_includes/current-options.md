## Current Options

Option | Description
--- | ---
name | Current stack name as it appear in the CloudFormation console.  This is used on commands that refer to existing stacks. It does not get use with the `lono create` command, where you must specify the stack name explicity.
suffix | The suffix to append or remove from the stack name. The suffix only gets appended on with the `lono create` command. Other lono commands that refer to existing stacks like `lono update` will not append the suffix and only remove the suffix internally for the `--template` option.
