lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jets/version"
require "jets/rdoc"

Gem::Specification.new do |spec|
  spec.name = "jets"
  spec.version = Jets::VERSION
  spec.author = "Tung Nguyen"
  spec.summary = "Serverless Deployment Service"
  spec.description = "Jets is a Serverless Deployment Service. Jets makes it easy to deploy and run your app on Serverless. It packages up your code and runs it on AWS Lambda. Jets can deploy Rails, Sinatra, and any Rack app."
  spec.homepage = "https://rubyonjets.com"
  spec.license = "MIT"

  spec.required_ruby_version = [">= 2.7.0"]
  spec.rdoc_options += Jets::Rdoc.options

  vendor_files = Dir.glob("vendor/**/*")
  gem_files = `git -C "#{File.dirname(__FILE__)}" ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|docs)/})
  end
  spec.files = gem_files + vendor_files
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-logs", ">= 1.0"
  spec.add_dependency "aws-mfa-secure", ">= 0.4.0"
  spec.add_dependency "aws-sdk-apigateway"
  spec.add_dependency "aws-sdk-cloudformation"
  spec.add_dependency "aws-sdk-cloudwatchevents"
  spec.add_dependency "aws-sdk-cloudwatchlogs"
  spec.add_dependency "aws-sdk-codebuild"
  spec.add_dependency "aws-sdk-dynamodb"
  spec.add_dependency "aws-sdk-ecs"
  spec.add_dependency "aws-sdk-iam"
  spec.add_dependency "aws-sdk-kinesis"
  spec.add_dependency "aws-sdk-lambda"
  spec.add_dependency "aws-sdk-s3"
  spec.add_dependency "aws-sdk-sns"
  spec.add_dependency "aws-sdk-sqs"
  spec.add_dependency "aws-sdk-ssm"
  spec.add_dependency "aws-sdk-wafv2"
  spec.add_dependency "cfn_camelizer", ">= 0.6.0"
  spec.add_dependency "cfn_response"
  spec.add_dependency "cfn-status", ">= 0.6.1"
  spec.add_dependency "cli-format", ">= 0.6.1"
  spec.add_dependency "dotenv", ">= 3.1"
  spec.add_dependency "dsl_evaluator", ">= 0.3.0" # for DslEvaluator.print_code
  spec.add_dependency "fugit"
  spec.add_dependency "gems"
  spec.add_dependency "hashie"
  spec.add_dependency "kramdown"
  spec.add_dependency "memoist"
  spec.add_dependency "mime-types"
  spec.add_dependency "rack"
  spec.add_dependency "rainbow"
  spec.add_dependency "recursive-open-struct"
  spec.add_dependency "shellwords"
  spec.add_dependency "text-table"
  spec.add_dependency "thor"
  spec.add_dependency "tty-screen"
  spec.add_dependency "zeitwerk", ">= 2.6.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "render_me_pretty"
  spec.add_development_dependency "rspec"
end
