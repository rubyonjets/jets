---
title: Custom Inflections
---

Jets lookups folders, files, and classes based on naming conventions. It singularizes or pluralizes words as a part of this naming convention. For example:

controller | model | views folder
--- | --- | ---
PostsController | Post | app/views/posts
ToysController | Toy | app/views/toys

Sometimes you might want to override the grammatical inflections.  You can do this by configuring a `config/inflections.yml` with your own custom inflections.  Example:

config/inflections.yml:

```yaml
octopus: octopi
person: people
hi: hi
```

This changes the singularization and pluralization of words to fit your needs.

