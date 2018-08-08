---
title: "Tutorial: Project Structure"
---

 They `lono new` command set up a lono project structure to help you know where things go. For a brand new project, most of the folders are still empty.

```sh
$ tree autoscaling
autoscaling
├── app
│   ├── definitions
│   │   └── base.rb
│   ├── helpers
│   ├── partials
│   ├── scripts
│   ├── templates
│   └── user_data
├── config
│   ├── params
│   ├── settings.yml
│   └── variables
└── output
$
```

Here's an overview of the directory structure and the purpose of each folder:

{% include structure.md %}

The Folders Overview above might be a little bit much if is your first time looking at the full lono prject structure.  A new project has most of the folders empty though. They are only needed if you use them.  In the next section we'll start to fill out some of the folders by importing an AutoScaling template.
