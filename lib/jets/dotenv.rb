require "dotenv"

module Jets
  class Dotenv
    include Jets::AwsServices
    include Jets::Util::Logging

    def load!
      return unless load?
      variables = ::Dotenv.load(*dotenv_files)
      Ssm.new(variables).interpolate!
    end

    def parse
      return {} unless load?
      variables = ::Dotenv.parse(*dotenv_files)
      Ssm.new(variables).interpolate!
    end

    def load?
      enabled = ENV["JETS_DOTENV"] != "0" # allow to disable with JETS_DOTENV=0
      # Prevent ssm calls when on AWS Lambda but will call if on AWS CodeBuild
      on_aws = (ENV["ON_AWS"] || ENV["_HANDLER"]) && !ENV["CODEBUILD_CI"]
      enabled && !on_aws
    end

    # dotenv files with the following precedence:
    #
    # - config/jets/env/.env.dev.extra (highest)
    # - config/jets/env/.env.dev
    # - config/jets/env/.env - The original (lowest)
    #
    def dotenv_files
      files = []

      files << ".env.#{Jets.env}.#{Jets.extra}" if Jets.extra
      files << ".env.#{Jets.env}"
      files << ".env"

      files.map! { |f| Jets.root.join("config/jets/env", f) }.compact
      files.map(&:to_s)
    end

    class << self
      extend Memoist
      @@load = nil
      def load!
        @@load ||= new.load!
      end
      memoize :load!

      @@parse = nil
      def parse
        @@parse ||= new.parse
      end
      memoize :parse
    end
  end
end
