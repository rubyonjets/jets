# Change Log

All notable changes to this project will be documented in this file.
This project *loosely tries* to adhere to [Semantic Versioning](http://semver.org/).

## [3.0.2] - 2021-01-12
- update serverlessgems gem

## [3.0.1] - 2021-01-12
- [#524](https://github.com/boltops-tools/jets/pull/524) fix native gem detection

## [3.0.0]
* #328 i18n docs
* #391 Deploy Option: Auto Replace API Gateway
* #444 Ruby 2.7 Support
* #453 Update to Bootstrap4 official release
* #454 When the controller name is singular, the behavior of searching for the View file is different from expected.
* #457 Breaking change: Harden IAM policy and do allow list all buckets by default. Breaking change.
* #479 Create request completion log method
* #487 API Gateway Base Path
* #488 Add retry_limit and read_timeout options
* #491 Fix queryStringParameters handling for nested value in spec_helper
* #492 Add params keyword case with get method for spec helpers test
* #494 Update ruby_packager.rb
* #496 Add unicode test for spec_helpers test
* #499 default_iam_policy does not correctly include VPC related actions on resource creation
* Improve autoloader: Shouldnt have to to call `bundle exec` in front of jets anymore.
* `jets configure` command
* Big improvements to docs site, add search
* Use serverlessgems API
* Breaking: use do not pluralize controller names for views folder
* Shorten SSM secrets notation support
* Remove deprecations and warnings: bundle install, generate scaffold, webpacker, yarn license, etc
* Also setting the `config.iam_policy` appends to the default policy now.
* Upgrade to Rails 6.1 components
* Increase cloudformation output limit to 200
* Replace `--sure` with `-y` option
* Fix params helper in views
* Webpacker upgrade

## [2.3.18]
- #514 Allow to define route that contains dot
- #515 set content type on upload by using extension so cloudfront will compress when serving
- #517 support nested query params in tests

## [2.3.17]
- #472 Docs: Update cors-support.md
- #475 Docs: Update activerecord.md to include db:create step
- #476 Docs: Update authorizer-cognito.md
- #482 Docs: Fixed description for "jetpacker" gem in Gemfile
- #483 Docs: controllers Fix minor typo
- #489 Docs: call typo
- #490 Docs: authorizers typo
- #504 Docs: tutorial series
- #505 Docs: display more tutorial articles
- #509 Docs: Update lamdba permissions for minimal-iam-policy doc
- #512 Bug fix: fix on_lambda? check allow testing #512

## [2.3.16]
- #466 fix application_config typo
- #467 Handle forbidden error from s3
- #468 authorization_scopes
- #469 Fixed typo from STMP to SMTP
- #470 remove json dependency
- #471 use `Bundler.with_unbundled_env` remove bundler deprecation

## [2.3.15]
- #461 fix guesser lookup for long function names

## [2.3.14]
- #432 filtered_parameters support
- #447 improve nested routes support. order routes so that nested resources always work
- #451 Fix Jets turbo DB encoding
- #452 Print Cfn templates location after build
- #458 update webpacker fork with jetpacker gem
- #459 fix afterburner mode

## [2.3.13]
- #430 Remove out-of-date note about FIFO Queue
- #433 Fixed ApiResources with long names not included in the main CloudFormation template
- #435 fix typo SMTP
- #437 Ignore *.local files when JETS_ENV_REMOTE=1
- #438 Forcing sort of initializers
- #446 temp fix for actionmailer turbine initializer
- update to ruby 2.5.7

## [2.3.12]
- #421 use underscore for database name in database.yml
- #422 url_for: allow any activemodel compatiable object to work
- #423 add apex domain support
- #424 md5 fix subtle bug when code doesnt get uploaded from newly generated shims
- #425 add hosted zone id support
- #426 use headers origin for actual host in case of cloudfront in front
- #428 fixes to JETS_BUILD_NO_INTERNET env var option
- #429 fix simple function tmp_loader

## [2.3.11]
- #419 Added forward slash before script_name env variable, so that correct path get generated. As it happens Rails

## [2.3.10]
- #418 Setting `ENV["SCRIPT_NAME"]` same as mount_at value.

## [2.3.9]
- #415 docs: aws cli install required, also note how to deploy to multiple regions
- #417 'jets call' honours region configuration

## [2.3.8]
- #410 Fix `render` doesn't recognize relative patial path with haml
- #412 attempt at fixing STI and hot reloading issue
- #413 add config.hot_reload option to allow override
- #414 more narrow check for /gems/ for caller_lines search

## [2.3.7]
- ensure at least cfn_camelizer 0.4.6 installed

## [2.3.6]
- #407 Fix error with 'references' in jets generate model
- #408 add note about database adapter to quick start, also link to more docs
- #409 enable sse-s3 encryption on parent s3 bucket by default

## [2.3.5]
- #397 kinesis_stream dsl method.
- #401 use `reconnect: true` for skeleton database.yml
- #402 mfa support

## [2.3.4]
- #395 Stay under Outputs Limits for large Jets apps. remove unused outputs
- use vendor/cfn-status: poll CloudFormation stack events for large stacks

## [2.3.3]
- fix sqs_queue

## [2.3.2]
- #394 introduce internal_finisher to fix shared resource extensions

## [2.3.1]
- #378 use JETS_TEST=1 env var instead of TEST=1 and favor Jets.env.test? method
- #382 associated resources support for controllers
- #383 add jets and code version to parent template description
- #384 upload template to s3
- #386 Allow Jets.once to be called in simple function
- #387 remove .bundle/config instead of BUNDLE_IGNORE_CONFIG=1
- allow accidental mount at / to work also

## [2.3.0]
- #377 routes mount support

## [2.2.5]
- #374 fix rspec execution for projects with no database
- #375 add jets dotenv:show command

## [2.2.4]
- #346 Check that migrations have been ran as part of running project specs. If migrations haven't ran, exit and report an error.

## [2.2.3]
- add newline so github edits dont case extra codebuild commit
- #372 fix to allow using only cognito authorizers

## [2.2.2]
- #370 Use unicode for encoding when using postgres

## [2.2.1]
- #369 clean up authorizers and bug fixes

## [2.2.0]
- #368 API Gateway Authorizer Concept Support

## [2.1.7]
- #366 fix copy ruby version
- fix codebuild for docs

## [2.1.6]
- #364 Add stagger deploy option: https://rubyonjets.com/docs/extras/deploy-stagger/
- codebuild: add caching to speed up build

## [2.1.5]
- perform_later calls perform_now in local mode when not on lambda
- fix: clear view cache in development mode

## [2.1.4]
- allow jets code to access event object values with symbols also

## [2.1.3]
- #359 redirect_back controller method
- fix default_protect_from_forgery to account for api mode
- fix md5 files.reject

## [2.1.2]
- improve start .env.development example for postgres
- #351 Update Turbine documentation
- #355 improve jets routes command to also validate routes
- #356 improvements to named route helpers
- #357 paginate api gateway resources to support more routes
- #358 rate limit backoff

## [2.1.1]
- #347 Add documentation about torch vs. warm
- #348 Provide another minimal privileges example
- #349 Fix route params for specs
- #350 Fix config.autoload_paths setting
- remove the jets c warning

## [2.1.0]
- #345 upgrade to use rails 6 components

## [2.0.6]
- #344 controller `helper_method` macro

## [2.0.5]
- #333 Always keep vendor directory
- #335 Controller action_name method
- #336 Escape paths passed to rsync
- #338 Support for "apiKeyRequired" option for API method
- #339 Implement endpoint_policy configuration
- #340 Fix tidy_spec from #333
- #341 Return exist status 1 if deployment fails
- #342 Adding support for `:only` option, to the skip\_before_action method
- #343 spec helpers: dont cache request headers between specs

## [2.0.4]
- #332 spec helpers: include routes helper

## [2.0.3]
- #331 spec_helpers fixes: response.headers support, fix session, run spec controller through middleware

## [2.0.2]
- #322, #325, #326, #329 update docs
- #330 fix remove Rails const

## [2.0.1]
- #319 improve mega mode or afterburner, start back up rack process if it dies for any reason

## [2.0.0]
- #318 Major Routing upgrade
- Routing Upgrades: nested resources, namespace, scope, singular resource
- Name routes helpers
- Forgery protection
- Generators upgrades: scaffold, controller, model, job, etc
- Autoload Rake tasks in lib/tasks.
- Update upgrading docs

## [1.9.32]
- #317 fix jets deploy when no /tmp/jets exists yet

## [1.9.31]
- #307 Update comment in Gemfile template
- #315 Improve spec_helpers: Use Rack::Multipart utils to properly build body params (especially with files and nested hashes)from galetahub/master
- #316 Copy .ruby-version file to build directory

## [1.9.30]
- #305 allow url paths that contain dashes

## [1.9.29]
- #303 API Gateway: Do not generate resource names longer than 62 characters
- #304 Add skip\_before\_action and skip\_after\_action method callbacks

## [1.9.28]
- #302 improve jets call guesser, do a simple detection at the start

## [1.9.27]
- sync stdout by default

## [1.9.26]
- fix ssm dotenv support: ensure Jets.config.project_name is set

## [1.9.25]
- load dotenv earlier so can use in config/application.rb

## [1.9.24]
- #301 Fix jets call for long function names. Lookup actual function names for long functions

## [1.9.23]
- #300 use .jets/project folder for afterburner instead of .jets/app

## [1.9.22]
- allow usage of env vars in class methods

## [1.9.21]
- #299 shorten auto-generated iam policy for vpc

## [1.9.20]
- #298 remove network calls on jets bootup process
- set AWS_ACCOUNT env var on function to prevent the sts call on Jets.boot on AWS Lambda
- dont load dotenv on aws lambda, already defined

## [1.9.19]
- #295 dotenv env extra support, fix precedence again
- #296 automatically add vpc permissions when using vpc_config at the application-wide iam level

## [1.9.18]
- #233 SSM Parameter Store support for dotenv files
- #293 Improvements to SSM Parameter Store support

## [1.9.17]
- #292 fix routes change detection, aws_lambda client

## [1.9.16]
- Removed #290, can use the application-wide IAM policy instead

## [1.9.15]
- #289 add sqs url to shared sqs queue resource
- #290 allow adjustment for preheat job iam policy

## [1.9.14]
- #288 fix shared eager loading so only shared classes are loaded
- #287 fix lambda url on the jets call command

## [1.9.13]
- #285 optimize by moving reloader middleware after shotgun static middleware

## [1.9.12]
- #284 use `@@reload_lock` class variable instead of global variable

## [1.9.11]
- #283 use mutex during reloading

## [1.9.10]
- #276 Correct CloudFormation debugging url
- #277 hot reload views for development mode

## [1.9.9]
- #275 warn about bundler/setup failure

## [1.9.8]
- #272 Jets Autoloaders with zeitwerk
- #273 remove need for forked rails
- #274 remove jets-gems as vendor dependency

## [1.9.7]
- #271 fix deploy for job mode with no config/routes.rb file

## [1.9.6]
- #268 Fix starter crud.js due to core-js module
- #269 Bundler.setup to fix namespace autovivification

## [1.9.5]
- #266 replace classify with camelize

## [1.9.4]
- #265 bug fix: show jets url at the end of a jets deploy

## [1.9.3]
- #264 auto reload routes for development

## [1.9.2]
- #232 Rename lambda method to aws_lambda to avoid ruby keyword collision
- #259 fix stage name in dev mode for redirect also
- #262 Handle nil body on mega request proxy
- #263 fix for static files now that not using shotgun

## [1.9.1]
- #257 dont generate handlers for concerns
- #258 from Fix custom domain base mapping

## [1.9.0]
- #249 docs grammar improvements
- #252 docs cli improvements
- #254 speed up development auto reloading
- #256 dont add /dev prefix if on_cloud9

## [1.8.14]
- update jets-gems

## [1.8.13]
- s3_event: fix s3 bucket ensure_exists check

## [1.8.12]
- #243 Update activerecord docs
- #244 Make ENV['HOME'] an absolute path because some file operations will barf otherwise
- #247 Fix Jets afterburner: fix wait_for_socket on aws lambda, rescue Errno::EAFNOSUPPORT

## [1.8.11]
- #242 adjust resp when request coming from elb
- update jets generate scaffold post casing

## [1.8.10]
- #208 add jets degenerate as opposite of generator
- #219 fix circleci usage, remove CIRCLECI env
- #222 fix config.function.dead_letter_config in starter application.rb
- #223 add jets degenerate as opposite of generator cleanup
- #224 add jets degenerate as opposite of generator cleanup
- #228 organize docs better into subfolders
- #230 Fix ValidationError branch of Cfn::Ship#update_stack
- #231 Add git submodules to contributing documentation.
- #234 Better API mode controller generator
- #238 Fix routing link in considerations-api-gateway doc
- #239 autoload concerns and allow them to work

## [1.8.9]
- JETS\_DEBUG\_EAGER_LOAD flag
- #216 fix webpacker v3.5 to v4 upgrade related issues

## [1.8.8]
- #206 cache aws service clients globally for lambda performance
- #211 Jets controller rescue_from support http://rubyonjets.com/docs/rescue-from/
- #212 fix s3 event function for long bucket names

## [1.8.7]
- #204 from CodingAnarchy/boot-missing-env
- #205 rename to rule_event
- add ref helper method
- deprecate: events_rule and event_pattern

## [1.8.6]
- #202 fix on_aws detection when using cloud9 hostname. Fixes #201
- user friendly error message when s3 bucket name has already been taken

## [1.8.5]
- #198 DynamoDB Stream Event Support
- #199 Kinesis Event support

## [1.8.4]
- rename s3_event_message to s3_event helper

## [1.8.3]
- #196 CloudWatch Log Event support
- #197 IoT Event Support

## [1.8.2]
- fix Jets.on_exception reporting

## [1.8.1]
- #194 fix jets eager load, order by path length
- #193 jets new fails during jets webpacker:install

## [1.8.0]
- #191 Email Support via ActionMailer
- #192 S3 Event Support
- Turbine after_initializer
- Improve Jets.boot ordering

## [1.7.2]
- #189: spec_helpers: `get` request now converts dangling params to query params. `query` keyword can be used to do the same thing explicitly.
- #190 SNS Event Lambda Trigger Support
- Start rack server on 127.0.0.1 for mega mode

## [1.7.1]
- fix Turbines with no initializer blocks

## [1.7.0]
- #188 sqs event support

## [1.6.9]
- #184 improve default cors options request access-control-allow-methods

## [1.6.8]
- #181 cors middleware
- #182 more robust handler shim
- fix polymorphic get_source_path path
- only upgrade config.ru if exists

## [1.6.7]
- update faq: JETS_AGREE no interruption flag

## [1.6.6]
- #175 Fix invalid route changes reading routine when route contains more than one variable in path
- #175 Fix invalid lambda function names for controllers in deep namespaces like A::B::MyController
- #176 fix cors for specific domains
- #177 check if rsync is installed. also stop on sh fail
- #178 strip trailing period from custom domain if accidentally set

## [1.6.5]
- #173 application/xml content-type on render xml

## [1.6.4]
- #171 fix precedence of dotenv files
- update cors comment on generated skeleton app

## [1.6.3]
- #168 cors specific authorization_type, default none
- cors defaults to false. enabled with config.cors = true in config/application.rb

## [1.6.2]
- #165 remove always trailing slash from Jets.root
- #166 fix cors headers
- #167 controller authorization_type declaration

## [1.6.1]
- #162 from patchkit-net/feature/spec_helpers
- #163 from tongueroo/spec-helpers
- Add jets/spec/helpers.rb with rails-style controller testing helpers
- #164 from tongueroo/encoding-fix: use encoding from content-type for mega request
- use rainbow gem for terminal colors

## [1.6.0]
- #158 from mmyoji/fix-docs-urls
- #159 from patchkit-net/bugfix/invalid-longpath-collision Fix invalid collision detection on paths that already contains path variables
- #161 from tongueroo/iam-role-name remove pretty iam role name, let CloudFormation generate

## [1.5.10]
- #157 Improve Route Change Detection: Path Variables

## [1.5.9]
- #154 from tongueroo/variable-collision raise error on multiple sibling variable paths collision
- #156 from konnected-io/master: don't prewarm jobs, only prewarm controllers
- ensure remove BUNDLED WITH remove when no project Gemfile.lock and it gets created by build process
- jets upgrade: add dynomite to gemfile if needed
- only clean submodules for bundler version 2+
- turbo wrapper project: remove Gemfile.lock and let afterburner mode run on latest jets version
- use pessimistic version for dependencies

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
- #136 from tongueroo/routes-namespace routes namespace support (experimental: will be adjusted)

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
