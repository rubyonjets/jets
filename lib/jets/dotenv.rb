require 'dotenv'

class Jets::Dotenv
  def self.load!(remote=false)
    new(remote).load!
  end

  def initialize(remote=false)
    @remote = remote
    @remote = ENV['JETS_ENV_REMOTE'] if ENV['JETS_ENV_REMOTE']
  end

  def load!
    ::Dotenv.load(*dotenv_files)
  end

  # dotenv files will load the following files, starting from the bottom. The first value set (or those already defined in the environment) take precedence:

  # - `.env` - The Original®
  # - `.env.development`, `.env.test`, `.env.production` - Environment-specific settings.
  # - `.env.local` - Local overrides. This file is loaded for all environments _except_ `test`.
  # - `.env.development.local`, `.env.test.local`, `.env.production.local` - Local overrides of environment-specific settings.
  #
  def dotenv_files
    files = [
      root.join(".env"),
      (root.join(".env.local") unless Jets.env.test?),
      root.join(".env.#{Jets.env}"),
      root.join(".env.#{Jets.env}.local"),
    ]
    files << root.join(".env.#{Jets.env}.remote") if @remote
    files.compact
  end

  def root
    Jets.root || Pathname.new(ENV["JETS_ROOT"] || Dir.pwd)
  end
end
