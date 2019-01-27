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
end
