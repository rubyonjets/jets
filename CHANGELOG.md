# Change Log

All notable changes to this project will be documented in this file.
This project *loosely tries* to adhere to [Semantic Versioning](http://semver.org/), even before v1.0.

## [1.5.8]
- #155 remove BUNDLED WITH from Gemfile.lock to fix newly released bundler issue

## [1.5.7]
- Fix prepend_* callbacks: These could modify a global callback array if used first

## [1.5.6]
- #149 from patchkit-net/feature/prepend-append-callbacks Add prepend/append_before_action and prepend/append_after_action callbacks
- #150 special s3 url for us-east-1

## [1.5.5]
- #148 check reserved lambda variables and let user know

## [1.5.4]
- #146 add and point to helpful docs on deploy error
- #147 update turbo Gemfile.lock, fixes Jets afterburner when using custom layers
- slimmer job mode Gemfile

## [1.5.3]
- #142 from tongueroo/rails-api-afterburner fix jets afterburner for rails api mode apps

## [1.5.2]
- #138 from patchkit-net/feature/before_action_chain_break Change before_action behavior: allow chain break
- #139 from patchkit-net/bugfix/spec-gem-files-dir Fix jets.gemspec files listing method
- #140 from patchkit-net/feature/config-logger Add configurable Jets.application.config.logger
- Change before_action behavior: When any before action renders or redirects, the filter chain
  is halted, and action code is not executed. This allows before_action to act as guards.
- Fix jets.gemspec how git command is executed to list files. The listing no longer needs to be done
  from the jets root directory. This change enables including Jets as local bundler gem.
- Add Jets.application.config.logger field to enable custom logger instance to
  be configured in config/environments/*.rb files.
- Fix scaffold ajax redirect url

## [1.5.1]
- #137 from tongueroo/gems-check bypass gems check exit for custom lambda layers

## [1.5.0]
- #135 from tongueroo/remove-rails-constant Remove Rails Constant
- #136 from tongueroo/routes-namespace routes namespace support (will be adjusted)

## [1.4.11]
- #133 from tongueroo/custom-layer add custom lambda layer support
- #134 from tongueroo/remove-dynomite-vendor remove vendor/dynomite

## [1.4.10]
- update vendor/dynomite: fix index creation dsl

## [1.4.9]
- update vendor/dynomite
- #128 from Atul9/update-license: update copyright year
- #130 from tongueroo/fix-specs

## [1.4.8]
- disable prewarm in `jets new` job mode

## [1.4.7]
- only create preheat job if prewarm.enable

## [1.4.6]
- #118 from tongueroo/fix-mega-query-string
- #120 from tongueroo/tidy-webpacker
- #123 from tongueroo/cp-r
- #124 from tongueroo/webpacker-update
- #125 from tongueroo/fix-redirect-for-custom-domains
- #126 from tongueroo/route-53-option config.domain.route53 option
- #127 from tongueroo/github-templates
- more specific regexp for project_name in parse_project_name
- tidy webpacker app/javascript/src and public/packs to keep code sizes down

## [1.4.5]
- include JETS_PROJECT_NAME as jets_env function var when set

## [1.4.4]
- #116 from tongueroo/assets: fix public assets folders to serve directly from s3

## [1.4.3]
- fix webpacker:compile on jets build and allow jets deploy to work standalone

## [1.4.2]
- fix webpacker:compile on jets build

## [1.4.1]
- allow jets url to run in afterburner mode
- #111 from tongueroo/db-seed fix jets db:seed
- #112 from tongueroo/jets-project-name fix JETS_ENV=production jets deploy
- allow JETS_PROJECT_NAME override

## [1.4.0]
- Afterburner mode: Allows you to deploy from within a Rails app
- #110 from tongueroo/jet-pack: Turbo charge mode: enabling afterburner
- Afterburner is recommended over Mega Mode.

## [1.3.9]
- #106 from eamsc/sqs-special-map
- #107 from eamsc/sqs-resource
- Added SQS sdk/client/resource for use in custom resources
- Fix shared ruby function runtime

## [1.3.8]
- Merge pull request #101 from eamsc/sqs-special-map Added SQS RedrivePolicy attributes to special map because they aren't being properly camelized.
- Merge pull request #102 from eamsc/resource-symbol-sub fix for undefined method `sub` for symbol

## [1.3.7]
- #100 from tongueroo/vendor-gems bundle in vendor/gems folder to avoid vendor/bundle collison
- use database from cli option in api mode for new

## [1.3.6]
- Merge pull request #91 from mveer99/patch-1 jets deploy production docs
- #96 from tongueroo/mega-mode-prod-deploy fix mega mode prod deploy, fix typo
- #97 from tongueroo/jets-delete-env support jets delete ENV
- #98 from tongueroo/support-import-bb-and-gitlab add import support for bitbucket and gitlab also

## [1.3.5]
- Merge pull request #90 from tongueroo/on-exception fix on_exception hook

## [1.3.4]
- fix gem replacer for macosx by using rsync to copy

## [1.3.3]
- Revert Merge pull request #88 from mveer99/master: faulty -T cp option for now

## [1.3.2]
- Merge pull request #88 from mveer99/master: faulty -T cp option

## [1.3.1]
- Merge pull request #87 from tongueroo/on-exception
- fix helpers for binary support
- deprecate report_exception in favor of on_exception
- docs: binary upload support

## [1.3.0]
- Official AWS Ruby Support
- Ruby Version 2.5.3 upgrade
- Gem Layer introduced
- Removed node shim
- Build purger: /tmp/jets/project is auto purge when major or minor version changes
- Update default gems source to https://gems2.lambdagems.com

## [1.2.1]
- remove comments about routes workaround, auto blue-green deployments resolves this

## [1.2.0]
- major upgrades: binary support, custom domain, bluegreen
- binary support
- custom domains support: http://rubyonjets.com/docs/routing-custom-domain/
- automated bluegreen deploy for api gateway when needed: http://rubyonjets.com/docs/blue-green-deployment/
- Merge pull request #84 from tongueroo/bluegreen

## [1.1.5]
- Support multiple path parameters. Also allow path parameters to hold any value other than '/'.
- Merge pull request #82 from adam-harwood/master

## [1.1.4]
- Fully qualify bundle install path, to fix issue when building on CodeBuild. Fixes #80.
- Merge pull request #81 from adam-harwood/master

## [1.1.3]
- Merge pull request #79 from tongueroo/misc-fixes
- fix has_poly? check to account for shared functions
- fix jets new mode job copy_options
- fix Jets Turbine require active support fixes issue #78
- parse for project name as workaround to avoid double loading config/application.rb

## [1.1.2]
- Add option to specify authorization type application-wide option and on a per-route basis.
- Add option to specify endpoint type of the ApiGateway: config.api.endpoint_type option
- pull request #74 from adam-harwood/route_authorization
- pull request #75 from adam-harwood/apig_endpoint_configuration
- pull request #76 from tongueroo/api-endpoint
- pull request #77 from tongueroo/api-auth
- fix jets new, comment out building of middleware during boot for now

## [1.1.1]
- provide instructions to run jets upgrade for config.ru update

## [1.1.0]
- rack compatibility pull request #72 from tongueroo/rack
- remove Jets::Timing pull request #73 from tongueroo/rm-timing

## [1.0.18]
- re-raise exception properly after reporting locally

## [1.0.17]
- Initial Jets Turbine support. http://rubyonjets.com/docs/jets-turbines/
- pull request #71 from tongueroo/turbine
- Addresses #70 Exception reporting

## [1.0.16]
- fix application iam policy when Jets::Application.default_iam_policy is used in config/application.rb
- #69 from tongueroo/fix-app-iam-policy

## [1.0.15]
- Fix polymorphic support: #67 from tongueroo/poly-fixes
- update .env.development example
- remove debugging puts

## [1.0.13]
- Fix notice when Jets fails to create first git commit This happens when user doesn't have git credentials available yet
- Merge pull request #63 from onnimonni/fix-missing-git-credentials

## [1.0.12]
- Fix notice when Jets tries to use aws-cli even when it's not available in PATH
- Merge pull request #62 from onnimonni/fix-notice-missing-aws-cli

## [1.0.11]
- Don't fail if AWS credentials are missing Fixes #60
- Merge pull request #61 from onnimonni/fix-missing-aws-credentials-local-server

## [1.0.10]
- remove emoji from skeleton index.html starter

## [1.0.9]
- adjust starter .env.development and config/application.rb

## [1.0.8]
- fix s3 assets to work with custom domains #58 from tongueroo/fix-assets

## [1.0.7]
- jets new: adjust skeleton template project
- jets import:rails: update config/database.yml

## [1.0.6]
- method fixes: account for inheritance and private keyword #57

## [1.0.5]
- change config.lambdagems to config.gems
- friendly info message when yarn is not installed
- improve rails:import rack/config/database.yml generation
- update gems check

## [1.0.4]
- import:rails reconfigure database.yml pull request #56 from tongueroo/database-yml

## [1.0.3]
- Allow control to prewarming of rack endpoint more
- add config.prewarm.rack_ratio setting pull request #55 from tongueroo/prewarm-rack-more

## [1.0.2]
- jets import:rails --submodule option. pull request #54 from tongueroo/import
- upgrade to jets-gems. pull request #53 from tongueroo/gems
- jets gems:check command
- jets gems:sources hidden command

## [1.0.1]
- jets upgrade command
- Merge pull request #52 from tongueroo/upgrade-command

## [1.0.0]
- Mega Mode: Rails Support, Rack Support
- jets import:rails command
- Lazy Loading Support
- MySQL support. MySQL is default for jets new command.
- Separate Environment configuration support
- Default function timeout 30s now and 60s for jobs
- Improve config/inflections.yml support
- Improve shim: organized code
- Improve static asset serving
- Improve deploy performance: lazy loading, separate zip files, and only reupload if md5 checksums change.
- Improve handler generation: ShimVars concept.
- Improve code builder: Tidy class
- Improve cfn builder: separate out cfn upload
- Improve Jets IO buffer handling
- Merge pull request #48 from tongueroo/megamode2

## [0.10.4]
- Merge pull request #51 from tongueroo/fix-aws-account: fix aws account lookup when ~/.aws/config not configured
- deprecate config.api_mode for api.mode = "api"

## [0.10.3]
- expose Jets::Application.default_iam_policy so user can re-use

## [0.10.2]
- fix cloudformation config rule permission race condition with depends on
- simplify --templates only cli option
- update config rules docs

## [0.10.1]
- clear @associated_properties bug
- fix jets new . , Merge pull request #46 from tongueroo/jets-new-dot
- update upgrade notes

## [0.10.0]
- Breaking: Changed logical ids. Refer to upgrading notes: http://rubyonjets.com/docs/upgrading/
- Merge pull request #45 from tongueroo/remove-internal-welcome
- Fix routing: Allow multiple paths to point to same controller action

## [0.9.2]
- s3 assets support: Merge pull request #44 from tongueroo/s3-assets

## [0.9.1]
- add upgrading notes
- fix iam policies: flatten

## [0.9.0]
- Breaking: Changed logical ids. Refer to upgrading notes: http://rubyonjets.com/docs/upgrading/
- Pretty big update: introduce concept of Shared Resources and Stack DSL
- Stack DSL: To support the concept of Custom Shared Resources. Supports extensions and simple functions also.
- Stack DSL: Allow for control of DependsOn attribute.
- Stack DSL: `MyStack.lookup` method
- Remove class name from the namespace. So namespace only has method name now. NOTE: This means upgrading from 0.8.x to 0.9.x requires a blue-green update.
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
