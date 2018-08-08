---
title: lono cfn
reference: true
---

## Usage

    lono cfn SUBCOMMAND

## Description

cfn subcommands

## Examples

    lono cfn create my-stack
    lono cfn preview my-stack
    lono cfn update my-stack
    lono cfn delete my-stack

## Subcommands

* [lono cfn create]({% link _reference/lono-cfn-create.md %}) - Create a CloudFormation stack using the generated template.
* [lono cfn current]({% link _reference/lono-cfn-current.md %}) - Current stack that you're working with.
* [lono cfn delete]({% link _reference/lono-cfn-delete.md %}) - Delete a CloudFormation stack.
* [lono cfn diff]({% link _reference/lono-cfn-diff.md %}) - Diff newly generated template vs existing template.
* [lono cfn download]({% link _reference/lono-cfn-download.md %}) - Download CloudFormation template from existing stack.
* [lono cfn preview]({% link _reference/lono-cfn-preview.md %}) - Preview a CloudFormation stack update. This is similar to terraform's plan or puppet's dry-run mode.
* [lono cfn status]({% link _reference/lono-cfn-status.md %}) - Shows the current status for the stack.
* [lono cfn update]({% link _reference/lono-cfn-update.md %}) - Update a CloudFormation stack using the generated template.
