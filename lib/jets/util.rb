require 'logger'

module Jets::Util
  # Ensures trailing slash
  # Useful for appending a './' in front of a path or leaving it alone.
  # Returns: '/path/with/trailing/slash/' or './'
  @@root = nil
  def root
    return @@root if @@root
    @@root = ENV['PROJECT_ROOT'].to_s
    @@root = '.' if @@root == ''
    @@root = "#{@@root}/" unless @@root.ends_with?('/')
    @@root
  end

  @@logger = nil
  def logger
    return @@logger if @@logger
    @@logger = Logger.new($stderr)
  end

  # TODO: Jets.boot: lazy load project classes instead of eager loading
  # Especially since Lambda functions will usually only require some of the
  # classes most of the time.
  def boot
    %w[
      app/controllers/application_controller
      app/jobs/application_job
      app/models/application_record
    ].each { |p| require "#{Jets.root}#{p}" }

    Dir.glob("#{Jets.root}app/**/*").each do |path|
      next unless File.file?(path)
      require path
    end
  end

  def env
    Jets::Config.env
  end

  def config
    Jets::Config.new.settings
  end
end
