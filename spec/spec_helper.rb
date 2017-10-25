ENV["TEST"] = "1"
ENV["PROJECT_ROOT"] = "./spec/fixtures/project"

# require "simplecov"
# SimpleCov.start

require "pp"
require "byebug"
require "fileutils"

root = File.expand_path("../../", __FILE__)
require "#{root}/lib/lam"

module Helpers
  def execute(cmd)
    puts "Running: #{cmd}" if ENV["DEBUG"]
    out = `#{cmd}`
    puts out if ENV["DEBUG"]
    out
  end
end

RSpec.configure do |c|
  c.include Helpers
end
