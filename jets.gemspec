# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jets/version"
require "jets/rdoc"

Gem::Specification.new do |spec|
  spec.name          = "jets"
  spec.version       = Jets::VERSION
  spec.author        = "Tung Nguyen"
  spec.email         = "tongueroo@gmail.com"
  spec.summary       = "Ruby Serverless Framework"
  spec.description   = "Jets is a framework that allows you to create serverless applications with a beautiful language: Ruby. It includes everything required to build and deploy an application.  Jets leverages the power of Ruby to make serverless joyful for everyone."
  spec.homepage      = "https://rubyonjets.com"
  spec.license       = "MIT"

  spec.required_ruby_version = ['>= 2.7.0']
  spec.rdoc_options += Jets::Rdoc.options

  vendor_files       = Dir.glob("vendor/**/*")
  gem_files          = `git -C "#{File.dirname(__FILE__)}" ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|docs)/})
  end
  spec.files         = gem_files + vendor_files
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "actionmailer", "~> 7.0.8"
  spec.add_dependency "actionpack", "~> 7.0.8"
  spec.add_dependency "actionview", "~> 7.0.8"
  spec.add_dependency "activerecord", "~> 7.0.8"
  spec.add_dependency "activesupport", "~> 7.0.8"
  spec.add_dependency "railties", "~> 7.0.8" # for ActiveRecord database_tasks.rb

  spec.add_dependency "aws-logs"
  spec.add_dependency "aws-mfa-secure", "~> 0.4.0"
  spec.add_dependency "aws-sdk-apigateway"
  spec.add_dependency "aws-sdk-cloudformation"
  spec.add_dependency "aws-sdk-cloudwatchlogs"
  spec.add_dependency "aws-sdk-dynamodb"
  spec.add_dependency "aws-sdk-kinesis"
  spec.add_dependency "aws-sdk-lambda"
  spec.add_dependency "aws-sdk-s3"
  spec.add_dependency "aws-sdk-sns"
  spec.add_dependency "aws-sdk-sqs"
  spec.add_dependency "aws-sdk-ssm"
  spec.add_dependency "cfn_camelizer", ">= 0.4.9"
  spec.add_dependency "cfn_response"
  spec.add_dependency "cfn-status"
  spec.add_dependency "cli-format", ">= 0.4.0"
  spec.add_dependency "dotenv"
  spec.add_dependency "dsl_evaluator", ">= 0.3.0" # for DslEvaluator.print_code
  spec.add_dependency "gems"
  spec.add_dependency "hashie"
  spec.add_dependency "jets-api", ">= 0.1.4"
  spec.add_dependency "jets-git"
  spec.add_dependency "jets-html-sanitizer"
  spec.add_dependency "kramdown"
  spec.add_dependency "memoist"
  spec.add_dependency "mini_mime"
  spec.add_dependency "rack"
  spec.add_dependency "rainbow"
  spec.add_dependency "recursive-open-struct"
  spec.add_dependency "text-table"
  spec.add_dependency "thor"
  spec.add_dependency "zeitwerk", ">= 2.6.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "render_me_pretty"
  spec.add_development_dependency "rspec"
end
