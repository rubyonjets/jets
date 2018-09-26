# Change Log

All notable changes to this project will be documented in this file.
This project *loosely tries* to adhere to [Semantic Versioning](http://semver.org/), even before v1.0.

## [0.9.2]
- s3 assets support: Merge pull request #44 from tongueroo/s3-assets

## [0.9.1]
- add upgrading notes
- fix iam policies: flatten

## [0.9.0]
- Remove class name from the namespace. So namespace only has method name now. NOTE: This means upgrading from 0.8.x to 0.9.x requires a blue-green update.
- Add upgrading docs.
- Stack DSL: To support the concept of Custom Shared Resources. Supports extensions and simple functions also.
- Stack DSL: Allow for control of DependsOn attribute.
- Stack DSL: `MyStack.lookup` method
- Associated resource extensions support
- Associated resources multiple form support: long, medium, short
- Add `jets new --mode`: 3 modes: html, api, job. Remove the `--api`
- IAM policies inherit from higher precedence and superclasses.
- Add `jets runner` command
- Fix AWS Config Rules support
- Rename event_rule to events_rule
- Remove submodule project demo fixture in favor of spec/fixtures/apps/franky
- Add spec/bin/integration.sh - Simpler than the CI one and more immediately useful
- Improve AWS Config Rules docs
- Add config rules namespace setting
- Custom inflections support

## [0.8.18]
- improve performance of Jets.aws.region, pull request #40 from tongueroo/dir-glob

## [0.8.17]
- fix Jets.eager_load

## [0.8.16]
- add minimal deploy iam policy docs
- harden deploy, auto delete minimal stack in rollback_completed
- Merge pull request #38 from tongueroo/harden-deploy-rollbacks

## [0.8.15]
- fix route resources macro for api mode pull request #35
- remove pg dependency from jets and add as part of project Gemfile pull request #36

## [0.8.14]
- Add faq docs
- add setting response headers support for cookies: pull request #31
- Replace `Timing` header with `X-Runtime`: pull request #30 from y8/patch-1

## [0.8.13]
- even simpler iam policy expansions: pull request #27 from tongueroo/iam
- specify rdoc options: pull request #28 from tongueroo/rdoc
- add gem version badge and specify ruby 2.5.x requirement in gemspec

## [0.8.12]
- fix jets gem summary and description

## [0.8.11]
- Inherit class properties from parent classes PR #25
- Make more puts like methods show up in cloudwatch logs
- Fix add_logical_id_counter to events

## [0.8.10]
- allow perform_now to run with default empty event
- fix env_properties in function resource, fixes stage name

## [0.8.9]
- clean up convenience properties and add rest of them PR #24

## [0.8.8]
- fix cron expression

## [0.8.7]
- add JETS_ENV_REMOTE and fix database config load for jets console

## [0.8.6]
- fix local server

## [0.8.5]
- Rename to Camelizer PR #23
- Fix helpers PR #22

## [0.8.4]
- fix custom iam policies
- fix edge case: allow stack to be delete in rollback completed state

## [0.8.3]
- adjust prewarm.public_ratio default to 10

## [0.8.2]
- add prewarm.public_ratio option: http://rubyonjets.com/docs/prewarming/

## [0.8.1]
- Upgrade all cfn resources to use the core jets resource model: request #21 from tongueroo/core-resource2
- Rid of mimimal-stack.yml and use jets core resource model
- Rescue encoding exception for the Jets IO flush to prevent process from crashing
- wip: binary support, set proper isBase64Encoded for binary content, but commented out binary media types due to form post breaking

## [0.8.0]
- Introduce core resource, pull request #20
- Future template generation will lead to core resource. Start the move away from the older cfn template generator logic.
- Allows for more control and customization of the associated resources with the lambda functions.
- Allows multiple associated resources to be connected to a lambda function.
- Support for CloudWatch event patterns, not just scheduled expression

## [0.7.1]
- fix application-wide config.iam_policy ability

## [0.7.0]
- add managed_iam_policy concept, pull request #19
- bump to 0.7.0, enough changes since 0.6.x

## [0.6.9]
- add aws managed rule support, pull request #18

## [0.6.8]
- add jets clean:log and clean:build commands pull request #17
- allow integration.sh test script to run locally

## [0.6.7]
- eager load jets lib also, pull request #16

## [0.6.6]
- improve puts handling: PR #15

## [0.6.5]
- fix prewarming after a deploy

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
