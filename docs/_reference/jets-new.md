---
title: jets new
reference: true
---

## Usage

    jets new

## Description

Creates a starter skeleton jets project.

## Examples

    $ jets new blog

Use the `--repo` flag to clone an example project from GitHub instead.  With this flag, jets new command clones a jets project repo from GitHub:

    $ jets new blog --repo tongueroo/tutorial
    $ jets new blog --repo tongueroo/todos
    $ jets new blog --repo user/repo # any github repo

## Options

```
[--repo=REPO]                    # GitHub repo to use. Format: user/repo
[--force]                        # Bypass overwrite are you sure prompt for existing files.
[--api], [--no-api]              # API mode.
[--webpacker], [--no-webpacker]  # Install webpacker
                                 # Default: true
[--bootstrap], [--no-bootstrap]  # Install bootstrap css
                                 # Default: true
[--git], [--no-git]              # Git initialize the project
                                 # Default: true
[--noop], [--no-noop]            
```

