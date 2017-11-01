ENV["TEST"] = "1"
ENV["PROJECT_ROOT"] = "./spec/fixtures/project"
# Ensures aws api never called. Fixture home folder does not contain ~/.aws/credentails
ENV['HOME'] = "spec/fixtures/home"

# require "simplecov"
# SimpleCov.start

require "pp"
require "byebug"
require "fileutils"
require "aws-sdk"

# require "bundler"
# Bundler.require(:development)

root = File.expand_path("../../", __FILE__)
require "#{root}/lib/jets"

module Helpers
  def execute(cmd)
    puts "Running: #{cmd}" if ENV["DEBUG"]
    out = `#{cmd}`
    puts out if ENV["DEBUG"]
    out
  end
end

RSpec.configure do |c|
  c.before(:suite) do
    Aws.config.update(stub_responses: true)
    FileUtils.rm_rf("spec/fixtures/project/handlers")
  end

  c.include Helpers
end
