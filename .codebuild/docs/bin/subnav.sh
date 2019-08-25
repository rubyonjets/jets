#!/bin/bash -eux

cd docs
# Unsure why but if cli_docs.sh runs bundle first, then bundle wont use the right bundler file
export BUNDLE_GEMFILE=$(pwd)/Gemfile
bundle
bundle exec jekyll serve --detach

# Error: front_matter_parser-0.2.1/lib/front_matter_parser/syntax_parser/multi_line_comment.rb:19:in `match': invalid byte sequence in US-ASCII (ArgumentError)
# Workaround: https://stackoverflow.com/questions/17031651/invalid-byte-sequence-in-us-ascii-argument-error-when-i-run-rake-dbseed-in-ra
export RUBYOPT="-KU -E utf-8:utf-8" # fixes front_matter_parser error within the `jekyll-sort reorder` call

gem install jekyll-sort
jekyll-sort reorder # Updates nav_order front matter of pages that are in the nav
