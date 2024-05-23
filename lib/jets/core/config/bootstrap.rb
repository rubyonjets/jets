module Jets::Core::Config
  class Bootstrap < Base
    include Helpers
    # config settings
    include Cfn
    include Code
    include Codebuild
    include S3Bucket

    attr_accessor :infra, :logger
    def initialize(*)
      super
      @infra = false
      @logger = default_logger
    end

    def default_logger
      logger = ActiveSupport::Logger.new($stderr)
      logger.formatter = ActiveSupport::Logger::SimpleFormatter.new # no timestamps
      logger.level = ENV["JETS_LOG_LEVEL"] || :info
      logger
    end
  end
end
