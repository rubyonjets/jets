#!/bin/bash -eux

.cody/docs/bin/git_setup.sh
.cody/docs/bin/bundler_setup.sh
.cody/docs/bin/cli_docs.sh
.cody/docs/bin/subnav.sh
.cody/docs/bin/git_commit.sh