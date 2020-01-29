require 'dotenv'

class Jets::Dotenv
  def self.load!(remote=false)
    new(remote).load!
  end

  def initialize(remote=false)
    @remote = ENV['JETS_ENV_REMOTE'] || remote
  end

  def load!
    return if on_aws? # this prevents ssm calls if used in dotenv files
    vars = ::Dotenv.load(*dotenv_files)
    Ssm.new(vars).interpolate!
  end

  def on_aws?
    !!ENV['_HANDLER'] # https://docs.aws.amazon.com/lambda/latest/dg/lambda-environment-variables.html
  end

  # dotenv files with the following precedence:
  #
  # - .env.development.jets_env_extra (highest)
  # - .env.development.remote (2nd highest, only if JETS_ENV_REMOTE=1)
  # - .env.development.local (unless JETS_ENV_REMOTE=1)
  # - .env.development
  # - .env.local - This file is loaded for all environments _except_ `test` or unless JETS_ENV_REMOTE=1
  # - .env - The original (lowest)
  #
  def dotenv_files
    files = [
      root.join(".env"),
      (root.join(".env.local") unless (Jets.env.test? || @remote)),
      root.join(".env.#{Jets.env}"),
      (root.join(".env.#{Jets.env}.local") unless @remote),
    ]
    files << root.join(".env.#{Jets.env}.remote") if @remote
    if ENV["JETS_ENV_EXTRA"]
      files << root.join(".env.#{Jets.env}.#{ENV["JETS_ENV_EXTRA"]}")
    end
    files.compact
  end

  def root
    Jets.root || Pathname.new(ENV["JETS_ROOT"] || Dir.pwd)
  end
end
