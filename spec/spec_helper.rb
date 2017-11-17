ENV["TEST"] = "1"
ENV["JETS_ENV"] = "test"
ENV["APP_ROOT"] = "./spec/fixtures/apps/demo"
# Ensures aws api never called. Fixture home folder does not contain ~/.aws/credentails
ENV['HOME'] = "spec/fixtures/home"

# require "simplecov"
# SimpleCov.start

require "pp"
require "byebug"
require "fileutils"

# require "bundler"
# Bundler.require(:development)

root = File.expand_path("../../", __FILE__)
require "#{root}/lib/jets"
Jets.boot
require "aws-sdk-lambda" # for Aws.config.update

module Helpers
  def execute(cmd)
    puts "Running: #{cmd}" if ENV["DEBUG"]
    out = `#{cmd}`
    puts out if ENV["DEBUG"]
    out
  end

  def json_file(path)
    JSON.load(IO.read(path))
  end
end

RSpec.configure do |c|
  c.before(:suite) do
    Aws.config.update(stub_responses: true)
    FileUtils.rm_rf("spec/fixtures/project/handlers")
  end

  c.include Helpers
end
