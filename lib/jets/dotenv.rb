require "dotenv"

class Jets::Dotenv
  def self.load!(remote = false)
    new(remote).load!
  end

  def initialize(remote = false)
    @remote = ENV["JETS_ENV_REMOTE"] || remote
  end

  # @@vars cache to prevent multiple calls to Ssm
  # Tricky note: The cache also prevents the second call to Dotenv.load from
  # returning {} vars. Dotenv 3.0 will not return the vars if it has already been loaded
  # in the ENV. We want this side-effect due to the new way Dotenv 3.0 works.
  @@vars = nil
  def load!
    return @@vars if @@vars
    return if on_aws? # this prevents ssm calls if used in dotenv files
    vars = ::Dotenv.load(*dotenv_files)
    @@vars = Ssm.new(vars).interpolate!
  end

  def on_aws?
    return true if ENV["ON_AWS"]
    !!ENV["_HANDLER"] # https://docs.aws.amazon.com/lambda/latest/dg/lambda-environment-variables.html
  end

  # dotenv files with the following precedence:
  #
  # - .env.development.jets_extra (highest)
  # - .env.development.remote (2nd highest, only if JETS_ENV_REMOTE=1)
  # - .env.development.local (unless JETS_ENV_REMOTE=1)
  # - .env.development
  # - .env.local - This file is loaded for all environments _except_ `test` or unless JETS_ENV_REMOTE=1
  # - .env - The original (lowest)
  #
  def dotenv_files
    files = []

    files << files << root.join(".env.#{Jets.env}.#{Jets.extra}") if Jets.extra
    files << root.join(".env.#{Jets.env}.remote") if @remote
    files << root.join(".env.#{Jets.env}.local") unless @remote
    files << root.join(".env.#{Jets.env}")
    files << root.join(".env.local") unless Jets.env.test? || @remote
    files << root.join(".env")

    files.compact.map(&:to_s)
  end

  def root
    Jets.root || Pathname.new(ENV["JETS_ROOT"] || Dir.pwd)
  end
end
