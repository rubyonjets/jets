---
title: Search Tips
---

Here are some useful search tips that can help to make searching more effective.

## OR Searches

By default, searches for multiple terms are combined with OR. If a document matches at least one of the search terms, it will show in the results. So:

    install aws

Will always result in more results just `install` by itself.


## AND Searches

To do an AND search of "install AND aws" mark both terms as required, you use a `+` sign in front of each term. Example:

    +install +aws

This results in pages only with both exactly install and aws.

## Filter Terms

To filter "keywords", you use a `-` sign in front of each term. Example:

    +install -aws

This results in pages only with install but filter or reject any pages with aws.

## Wildcard

You can use wildcards:

    install*

## Fields

You can target specific fields:

    title:install

For fields see: [search data.json]({% link search/data.json %})

## More Tips

More search tips can be found at: [lunrjs searching](https://lunrjs.com/guides/searching.html)
