## Update Project

To update the CodeBuild project:

Main services:

    export AWS_PROFILE=bolt-oss
    cb deploy jets --type docs # mainly cli docs and subnav update

## Start a Deploy

To start a CodeBuild build which kicks off a deploy:

    cb start jets --type docs

To specify a branch:

    cb start jets --type docs --branch codebuild
