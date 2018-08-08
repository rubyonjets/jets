---
title: lono script upload
reference: true
---

## Usage

    lono script upload

## Description

Uploads `output/scripts/scripts-md5sum.tgz` to s3

This command must be ran after `lono script build` since it relies the artifacts of that command. Namely:

  * output/scripts/scripts-md5sum.tgz
  * output/data/scripts_info.txt

## Examples

    lono script upload
