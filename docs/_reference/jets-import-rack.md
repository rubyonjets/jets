---
title: jets import:rack
reference: true
---

## Usage

    jets import:rack

## Description

Imports rack project in the rack subfolder.

Imports a generic Rack application into a Jets project and configures it for [Mega Mode](http://rubyonjets.com/docs/megamode/).

Note, generic rack projects will likely need a little more adjustment to take into API Gateway stages and logging. For more info refer to [Mega Mode Considerations](http://rubyonjets.com//megamode-considerations/).

## Example

    jets import:rack http://github.com/tongueroo/jets-mega-rails.git

## More Examples

    jets import:rack tongueroo/jets-mega-rails # expands to github
    jets import:rack git@github.com:tongueroo/jets-mega-rails.git
    jets import:rack /path/to/folder/jets-mega-rails


