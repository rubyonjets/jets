require 'dotenv'

class Jets::Dotenv
  class << self
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
      [
        root.join(".env.#{Jets.env}.local"),
        (root.join(".env.local") unless Jets.env.test?),
        root.join(".env.#{Jets.env}"),
        root.join(".env")
      ].compact
    end

    def root
      Jets.root || Pathname.new(ENV["JETS_ROOT"] || Dir.pwd)
    end
  end
end
