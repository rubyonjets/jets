ENV["JETS_TEST"] = "1"
ENV["JETS_ENV"] = "test"
ENV["JETS_ROOT"] = "./spec/fixtures/apps/franky"
# Ensures aws api never called. Fixture home folder does not contain ~/.aws/credentials
ENV['HOME'] = File.join(Dir.pwd,'spec/fixtures/home')
ENV['SECRET_KEY_BASE'] = 'fake'
ENV['AWS_MFA_SECURE_TEST'] = '1'

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
  autoload :Multipart, "./spec/spec_helper/multipart"
  include Multipart

  def execute(cmd)
    puts "Running: TEST=1 JETS_ROOT=#{ENV['JETS_ROOT']} #{cmd}" if ENV['JETS_DEBUG']
    out = `#{cmd}`
    puts out if ENV['JETS_DEBUG']
    out
  end

  def json_file(path)
    JSON.load(IO.read(path))
  end

  def yaml_file(path)
    YAML.load_file(path)
  end

  # Only needed for specs since the application_spec calls iam_policy and internally
  # override Jets.application singleton. This affects other tests. The effected test need
  # to call this to reload config.iam settings.
  def reset_application_config_iam!
    Jets.application.config.iam_policy = nil
    Jets.application.config.default_iam_policy = nil
    Jets.application.set_iam_policy
  end
end

RSpec.configure do |c|
  c.before(:suite) do
    Aws.config.update(stub_responses: true)
    FileUtils.rm_rf("spec/fixtures/project/handlers")
  end

  c.include Helpers
end
