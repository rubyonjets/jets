---
title: lono cfn status
reference: true
---

## Usage

    lono cfn status

## Description

Shows the current status for the stack.

Shows the status of the stack. If the stack is in progress then tail the status and provide live updates.

## Examples

    $ lono cfn status ecs-asg
    The current status for the stack ecs-asg is UPDATE_COMPLETE
    Stack events:
    11:52:28PM UPDATE_IN_PROGRESS AWS::CloudFormation::Stack ecs-asg User Initiated
    11:52:32PM UPDATE_IN_PROGRESS AWS::CloudWatch::Alarm HighMemory
    11:52:32PM UPDATE_IN_PROGRESS AWS::CloudWatch::Alarm HighCpu
    11:52:32PM UPDATE_COMPLETE AWS::CloudWatch::Alarm HighMemory
    11:52:33PM UPDATE_COMPLETE AWS::CloudWatch::Alarm HighCpu
    11:52:35PM UPDATE_COMPLETE_CLEANUP_IN_PROGRESS AWS::CloudFormation::Stack ecs-asg
    11:52:36PM UPDATE_COMPLETE AWS::CloudFormation::Stack ecs-asg

If current name is set.

    lono cfn current --name ecs-asg
    lono cfn status


## Options

```
[--verbose], [--no-verbose]
[--noop], [--no-noop]
```
