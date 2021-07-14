---
title: Jetsignore
---

## .jetsignore

To keep the Lambda zip file size down, you might want to avoid packaging up large folders. You can do this with the `.jetsignore` file.  Example:

.jetsignore

    some/large/folder
    vendor/bundle

This tells Jets not to package up `some/large/folder` and `vendor/bundle`.

## .jetskeep

There's also a `.jetskeep` file concept. The default values for this is:

    .bundle
    /public/packs
    /public/packs-test
    vendor

This file tells Jets to keep these files regardless of what's configured with `.jetsignore`. So the `.jetskeep` has higher precedence than `.jetsignore`.

Note: If you create a `.jetskeep` file, it will override the defaults entirely.