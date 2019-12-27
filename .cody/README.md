## Update Project

To update the CodeBuild project:

Main services:

    AWS_PROFILE=bolt-oss cody deploy jets --type docs # mainly cli docs and subnav update

## Start a Deploy

To start a CodeBuild build which kicks off a deploy:

    AWS_PROFILE=bolt-oss cody start jets --type docs
