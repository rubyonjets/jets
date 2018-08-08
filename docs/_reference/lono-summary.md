---
title: lono summary
reference: true
---

## Usage

    lono summary STACK

## Description

Prints summary of CloudFormation template.

The `lono summary` command helps you quickly understand a CloudFormation template.

## Examples

    $ lono summary ec2
    => CloudFormation Template Summary:
    Parameters:
    Required:
      KeyName (AWS::EC2::KeyPair::KeyName)
    Optional:
      InstanceType (String) Default: t2.micro
      SSHLocation (String) Default: 0.0.0.0/0
    Resources:
      1 AWS::EC2::Instance
      1 AWS::EC2::SecurityGroup
      2 Total
    $

Blog Post also covers this: [lono summary Tutorial Introduction](https://blog.boltops.com/2017/09/18/lono-inspect-summary-tutorial-introduction)
