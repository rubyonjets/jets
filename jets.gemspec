# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jets/version"

Gem::Specification.new do |spec|
  spec.name          = "jets"
  spec.version       = Jets::VERSION
  spec.authors       = ["Tung Nguyen"]
  spec.email         = ["tongueroo@gmail.com"]
  spec.description   = %q{Test}
  spec.summary       = %q{Test}
  spec.homepage      = "https://github.com/tongueroo/jets"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|docs)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "hashie"
  spec.add_dependency "colorize"
  spec.add_dependency "activesupport"
  spec.add_dependency "actionview"
  spec.add_dependency "actionpack"
  spec.add_dependency "activerecord"
  spec.add_dependency "railties" # ActiveRecord database_tasks.rb require this
  # TODO: only load the database adapters that the app uses, so generate this
  # in the app's Gemfile
  spec.add_dependency "dotenv"

  spec.add_dependency "recursive-open-struct"
  spec.add_dependency "aws-sdk-s3"
  spec.add_dependency "aws-sdk-cloudformation"
  spec.add_dependency "aws-sdk-dynamodb"
  spec.add_dependency "aws-sdk-lambda"
  spec.add_dependency "kramdown"
  spec.add_dependency "memoist"
  spec.add_dependency "text-table"
  spec.add_dependency "rack"
  spec.add_dependency "json"
  # there are development dependencies because we want to lazy load them
  # in the app. but we want to have them so we can run specs.
  spec.add_dependency "pg", "=0.21"

  spec.add_dependency "gems" # lambdagem dependency

  spec.add_development_dependency "byebug"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  # ruby_dep-1.5.0 requires ruby version >= 2.2.5, which is incompatible with the current version, ruby 2.2.2p95
  # spec.add_development_dependency "guard"
  # spec.add_development_dependency "guard-bundler"
  # spec.add_development_dependency "guard-rspec"
  # spec.add_development_dependency "codeclimate-test-reporter", group: :test, require: nil
end
