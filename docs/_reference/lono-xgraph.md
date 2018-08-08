---
title: lono xgraph
reference: true
---

## Usage

    lono xgraph STACK

## Description

Graphs dependencies tree of CloudFormation template resources.

## Example

With more complex CloudFormation templates, the dependency can get difficult to follow.  Visualizing the dependencies is helpful.

    lono import https://s3.amazonaws.com/solutions-reference/aws-waf-security-automations/latest/aws-waf-security-automations.template --name waf
    lono xgraph waf

This above command generates a dependency chart.  The command uses the DependsOn attribute specified in each resource to figure this out.  It does not show implied dependencies that CloudFormaton automatically computes for us.  The chart looks like this:

![](/img/tutorial/waf-chart.png){:.doc-photo}

The chart is generated with [Graphviz](http://www.graphviz.org/). To install:

    brew install graphviz

Blog Post also covers this: [lono inspect depends Tutorial Introduction](https://blog.boltops.com/2017/09/20/lono-inspect-depends-tutorial-introduction)


## Options

```
[--display=DISPLAY]    # graph or text
                       # Default: graph
[--noop], [--no-noop]  # noop mode
```
