ENV["TEST"] = "1"
ENV["JETS_ENV"] = "test"
ENV["JETS_ROOT"] = "./spec/fixtures/apps/franky"
# Ensures aws api never called. Fixture home folder does not contain ~/.aws/credentails
ENV['HOME'] = "spec/fixtures/home"
ENV['SECRET_KEY_BASE'] = 'fake'

# require "simplecov"
# SimpleCov.start

require "pp"
require "byebug"
require "fileutils"

root = File.expand_path("../../", __FILE__)
require "#{root}/lib/jets"
Jets.boot
require "aws-sdk-lambda" # for Aws.config.update

module Helpers
  def execute(cmd)
    puts "Running: TEST=1 JETS_ROOT=#{ENV['JETS_ROOT']} #{cmd}" if ENV['JETS_DEBUG']
    exit
    out = `#{cmd}`
    puts out if ENV['JETS_DEBUG']
    out
  end

  def json_file(path)
    JSON.load(IO.read(path))
  end
end

# pretty hacky way of stubbing out md5_code_zipfile
Jets::Naming # autoload it
class Jets::Naming
  # override for specs
  def self.md5_code_zipfile
    "/tmp/jets/demo/code/code-2e0e18f6.zip"
  end
end

RSpec.configure do |c|
  c.before(:suite) do
    Aws.config.update(stub_responses: true)
    FileUtils.rm_rf("spec/fixtures/project/handlers")
  end

  c.include Helpers
end
