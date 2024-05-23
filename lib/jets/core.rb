module Jets::Core
  extend Memoist

  def root
    root = ENV["JETS_ROOT"].to_s
    root = Dir.pwd if root == ""
    Pathname.new(root)
  end
  memoize :root

  def env
    env = ENV["JETS_ENV"] || "dev"
    ActiveSupport::StringInquirer.new(env)
  end
  memoize :env

  def extra
    ENV["JETS_EXTRA"] unless ENV["JETS_EXTRA"].blank?
  end

  def project
    Config::Project.instance
  end

  def bootstrap
    Config::Bootstrap.instance
  end

  def shim
    Jets::Shim
  end

  # Load project and app config files
  def boot
    Jets::Core::Booter.boot!
  end

  # delegate :aws, :autoloaders, :config, to: :application
  def aws
    Jets::AwsServices::AwsInfo.new
  end
  memoize :aws

  # Frameworks can set Jets.logger to use their own logger.
  cattr_accessor :logger
  def logger
    @logger ||= Jets.bootstrap.config.logger
  end

  def build_root
    root = ENV["JETS_BUILD_ROOT"] || "/tmp/jets"
    "#{root}/#{Jets.project.namespace}".freeze
  end
  memoize :build_root

  def s3_bucket
    Jets::Cfn::Resource::S3::JetsBucket.name
  end

  def deprecator # :nodoc:
    @deprecator ||= ActiveSupport::Deprecation.new
  end

  def report_exception(exception)
    # See Jets::ExceptionReporting decorate_exception_with_exception_reported!
    if exception.respond_to?(:with_exception_reported?) && exception.with_exception_reported?
      return
    end

    Jets.application.turbines.each do |turbine|
      turbine.on_exception_blocks.each do |block|
        block.call(exception)
      end
    end
  end

  # Returns the ActiveSupport::ErrorReporter of the current \Jets project,
  # otherwise it returns +nil+ if there is no project.
  #
  #   Jets.error.handle(IOError) do
  #     # ...
  #   end
  #   Jets.error.report(error)
  def error
    application && application.executor.error_reporter
    # ActiveSupport.error_reporter
  end
end
