---
title: lono user_data
reference: true
---

## Usage

    lono user_data NAME

## Description

Generates user_data script for debugging.

Generates user_data scripts in `app/user_data` so you can see it for debugging. Let's say you have a script in `app/user_data/bootstrap.sh`. To generate it:

    lono user_data bootstrap

## Example Output

Script:

    #!/bin/bash -exu

    <%= extract_scripts(to: "/opt") %>

    SCRIPTS=/opt/scripts
    $SCRIPTS/install_stuff.sh

Running `lono user_data bootstrap` produces:

    $ lono user_data bootstrap
    Detected app/scripts
    Tarballing app/scripts folder to scripts.tgz
    => cd app && dot_clean .
    => cd app && tar -c scripts | gzip -n > scripts.tgz
    Tarball created at output/scripts/scripts-93b8b29b.tgz
    Generating user_data for 'bootstrap' at ./app/user_data/bootstrap.sh
    #!/bin/bash -exu

    # Generated from the lono extract_scripts helper.
    # Downloads scripts from s3, extract them, and setup.
    mkdir -p /opt
    aws s3 cp s3://mybucket/path/to/folder/development/scripts/scripts-93b8b29b.tgz /opt/
    cd /opt
    tar zxf /opt/scripts-93b8b29b.tgz
    chmod -R a+x /opt/scripts
    chown -R ec2-user:ec2-user /opt/scripts

    SCRIPTS=/opt/scripts
    $SCRIPTS/install_stuff.sh
    $


## Options

```
[--clean], [--no-clean]  # remove all output/user_data files before generating
                         # Default: true
```
