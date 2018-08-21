# Change Log

All notable changes to this project will be documented in this file.
This project *tries* to adhere to [Semantic Versioning](http://semver.org/), even before v1.0.

## [0.6.4]
- fix client.puts(result)

## [0.6.3]
- fix app logging: pull request #14

## [0.6.2]
- add versions to gemspec dependencies

## [0.6.1]
- only prewarm if Jets::PreheatJob.warm available

## [0.6.0]
- fine grain iam policy abilities: pull request #13 from tongueroo/iam-policy
- changed quite a few logical ids in the CloudFormation templates

## [0.5.8]
- fix config.prewarm defaults

## [0.5.7]
- adjust default function memory size to 1536

## [0.5.6]
- use Lambdagem.log_level = :info

## [0.5.5]
- clean old git submodules from cache to reduce cache bloat
- dont prewarm after deploy if disabled :pull request #12
- update docs

## [0.5.4]
- add route check before cloudformation update: pull request #11
- hide confusing debugging logs for node shim for user
- update docs, grammar fixes
- update initial welcome page, improve mobile, use encoding: utf-8 for starter index page
- update to use Jets::RUBY_VERSION

## [0.5.3]
- add x-jets-prewarm-count and x-jets-call-count headers: pull request #10 from tongueroo/call-count
- adjust default prewarming concurrency to 2
- Jets.eager_load as part of warmup
- rename config.prewarm.enable
- update docs

## [0.5.2]
- format the js error in the node shim properly

## [0.5.1]
- fix gemspec
- fix Docker base build, comment out unneeded broken maven
- update docs

## [0.5.0]
- First big good release

## [0.1.2]
- Fix bundled gems.
