ENV["JETS_TEST"] = "1"
ENV["JETS_ENV"] = "test"
# Ensures aws api never called. Fixture home folder does not contain ~/.aws/credentials
ENV['HOME'] = File.join(Dir.pwd,'spec/fixtures/home')
ENV['SECRET_KEY_BASE'] = 'fake'
ENV['AWS_MFA_SECURE_TEST'] = '1'

require "byebug"
require "fileutils"
require "memoist"
require "pp"

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
  end

  def draw(&block)
    route_set.clear! # from previous ran specs
    route_set.draw(&block)
    route_set.url_helpers.add_methods!
    routes = route_set.routes
    help = Jets::Router::Help.new(format: "space", header: false)
    allow(help).to receive(:routes).and_return(routes)
    text = help.text
    lines = text.split("\n")
    # Find the minimum number of leading spaces
    min_spaces = lines.reject { |line| line.strip.empty? }.map { |line| line.match(/^\s*/)[0].length }.min
    # Remove leading spaces while keeping alignment
    formatted_text = lines.map { |line| line[min_spaces..-1] }.join("\n") + "\n"
  end

  def find_route(path, http_method="GET")
    matcher = Jets::Router::Matcher.new
    allow(matcher).to receive(:routes).and_return(route_set.routes)
    matcher.find_by_env(
      "REQUEST_METHOD" => http_method,
      "PATH_INFO" => path,
    )
  end

  def silence_loggers!
    @old_logger = Jets.logger
    Jets.logger = ActionView::Base.logger = Logger.new("/dev/null")
  end

  def restore_loggers!
    Jets.logger = @old_logger
  end
end

RSpec.configure do |c|
  c.before(:suite) do
    Aws.config.update(stub_responses: true)
    FileUtils.rm_rf("spec/fixtures/project/handlers")
  end

  c.include Helpers
end

root = File.expand_path("../../", __FILE__)
require "#{root}/lib/jets"
Dir.chdir("#{root}/spec/fixtures/demo") do
  ENV['JETS_SKIP_ROUTES_LOAD'] = '1'
  Jets.boot
  # Pretty confusing to set JETS_ROOT after the boot, but it works for the specs
  # IE: stack/function_spec.rb
  ENV['JETS_ROOT'] = "spec/fixtures/demo"
end
require "aws-sdk-lambda" # for Aws.config.update

class RouterTestApp
  include Jets.application.routes.url_helpers
end
