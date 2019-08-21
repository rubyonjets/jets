#!/bin/bash -eux

.codebuild/docs/bin/git_setup.sh
.codebuild/docs/bin/cli_docs.sh
.codebuild/docs/bin/subnav.sh
.codebuild/docs/bin/git_commit.sh