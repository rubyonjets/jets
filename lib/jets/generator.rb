# Piggy back off of Rails Generators.
class Jets::Generator
  class << self
    def invoke(generator, *args)
      new(generator, *args).run(:invoke)
    end

    def revoke(generator, *args)
      new(generator, *args).run(:revoke)
    end

    def help(args=ARGV)
      # `jets generate -h` results in:
      #
      #     args = ["generate", "-h"]
      #
      args = args[1..-1] || []
      help_flags = Thor::HELP_MAPPINGS + ["help"]
      args.pop if help_flags.include?(args.last)
      subcommand = args[0]

      out = capture_stdout do
        if subcommand
          # Using invoke because it ensure the generator is configured properly
          invoke(subcommand) # sub-level: jets generate scaffold -h
        else
          puts Jets::Commands::Help.text(:generate) # to trigger the regular Thor help
          # Note: How to call the original top-level help menu from Rails. Keeping around in case its useful later:
          # Rails::Generators.help # top-level: jets generate -h
        end
      end
      out.gsub('rails','jets').gsub('Rails','Jets')
    end

    def capture_stdout
      stdout_old = $stdout
      io = StringIO.new
      $stdout = io
      yield
      $stdout = stdout_old
      io.string
    end

    def require_generators
      # lazy require so Rails const is only defined when using generators
      require "rails/generators"
      require "rails/configuration"
      require_active_job_generator
    end

    def require_active_job_generator
      require "active_job"
      require "rails/generators/job/job_generator"
      # Override the source_root
      Rails::Generators::JobGenerator.class_eval do
        def self.source_root
          File.expand_path("../generator/templates/active_job/job/templates", __FILE__)
        end
      end
    end
  end

  def initialize(generator, *args)
    @generator, @args = generator, args
    @args << '--pretend' if noop?
  end

  # Used to delegate noop option to Rails generator pretend option.  Both work:
  #
  #     jets generate scaffold user title:string --noop
  #     jets generate scaffold user title:string --pretend
  #
  # Grabbing directly from the ARGV because think its cleaner than passing options from
  # Thor all the way down.
  def noop?
    ARGV.include?('--noop')
  end

  def run(behavior=:invoke)
    self.class.require_generators

    Jets::Commands::Db::Tasks.load!

    Rails::Generators.configure!(config)
    Rails::Generators.invoke(@generator, @args, behavior: behavior, destination_root: Jets.root)
  end

  def config
    g = Rails::Configuration::Generators.new
    g.orm             :active_record, migration: true, timestamps: true
    # TODO: support g.orm :dynamodb
    g.test_framework  nil #:test_unit, fixture: false
    # g.test_framework :rspec # TODO: load rspec configuration to use rspec
    g.stylesheets     false
    g.javascripts     false
    g.assets          false
    if Jets.config.mode == 'api'
      g.api_only = true
      g.template_engine nil
    else
      g.template_engine :erb
    end
    g.resource_route  true
    g.templates.unshift(template_paths)
    g
  end

  def template_paths
    templates_path = File.expand_path("../generator/templates", __FILE__)
    [templates_path]
  end
end
