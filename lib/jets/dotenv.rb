require 'dotenv'
require 'aws-sdk-ssm'

class Jets::Dotenv
  SSM_VARIABLE_REGEXP = /^ssm:(.*)/

  def self.load!(remote=false)
    new(remote).load!
  end

  def initialize(remote=false)
    @remote = remote
    @remote = ENV['JETS_ENV_REMOTE'] if ENV['JETS_ENV_REMOTE']
  end

  def load!
    env = ::Dotenv.load(*dotenv_files)
    interpolate_ssm_variables(env)
  end

  # dotenv files with the following precedence:
  #
  # - .env.development.remote (highest)
  # - .env.development.local
  # - .env.development
  # - .env.local - This file is loaded for all environments _except_ `test`.
  # - .env` - The original (lowest)
  #
  def dotenv_files
    files = [
      root.join(".env"),
      (root.join(".env.local") unless Jets.env.test?),
      root.join(".env.#{Jets.env}"),
      root.join(".env.#{Jets.env}.local"),
    ]
    files << root.join(".env.#{Jets.env}.remote") if @remote
    files.reverse.compact # reverse so the precedence is right
  end

  def root
    Jets.root || Pathname.new(ENV["JETS_ROOT"] || Dir.pwd)
  end

  private

  def interpolate_ssm_variables(variables)
    interpolated_variables = variables.map do |key, value|
      if value[SSM_VARIABLE_REGEXP]
        value = fetch_ssm_value($1)
      end

      [key, value]
    end

    interpolated_variables.each do |key, value|
      ENV[key] = value
    end

    interpolated_variables.to_h
  end

  def fetch_ssm_value(name)
    name = "/#{Jets.application.config.project_name}/#{Jets.env}/#{name}" unless name.start_with?("/")
    response = ssm.get_parameter(name: name, with_decryption: true)
    response.parameter.value
  rescue Aws::SSM::Errors::ParameterNotFound
    abort "Error loading .env variables. No parameter matching #{name} found on AWS SSM.".color(:red)
  end

  def ssm
    @ssm ||= Aws::SSM::Client.new
  end
end
