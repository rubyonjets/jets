ENV["JETS_ENV"] = "test"
ENV["JETS_TEST"] = "1"
ENV["AWS_MFA_SECURE_TEST"] = "1"
# Ensures aws api never called. Fixture home folder does not contain ~/.aws/credentials
ENV["HOME"] = File.join(Dir.pwd, "spec/fixtures/shim/home")

require "aws-sdk-core"
require "byebug"
require "fileutils"
require "memoist"
require "pp"

root = File.expand_path("..", __dir__)
require "#{root}/lib/jets"

module Helpers
end

RSpec.configure do |c|
  c.before(:suite) do
    Aws.config.update(stub_responses: true)
  end

  c.include Helpers
end
