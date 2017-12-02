ENV["JETS_ENV"] = "test"
ENV["TEST"] = "1"
# Ensures aws api never called. Fixture home folder does not contain ~/.aws/credentails
ENV['HOME'] = "spec/fixtures/home"

# require "simplecov"
# SimpleCov.start

require "pp"
require "byebug"
require "fileutils"

require "jets"
Jets.boot

module Helpers
  def payload(name)
    JSON.load(IO.read("spec/fixtures/payloads/#{name}.json"))
  end
end

RSpec.configure do |c|
  c.before(:suite) do
    Aws.config.update(stub_responses: true)
  end
  c.include Helpers
end
