# Piggy back off of Rails Generators.

module Jets
  # Original Rails::Generators is a module.
  # It cannot be included or inherited given the way Rails module is defined.
  # We use a class that delegates to the Rails::Generators.invoke method.
  class Generators
    include Jets::Command::Behavior

    def initialize(namespace, args = ARGV, config = {})
      @namespace, @args, @config = namespace, args, config
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
      if @namespace == "job"
        run_job_generator
      else
        # Required by:
        #   jets generate migration create_articles user:references
        #   jets generate model article user:references
        # Makes use of Rails.application
        if %w[model migration].include?(@namespace)
          require "jets/overrides/dummy/rails"
        end
        run_rails_generator
      end
    end

    # For job generators, use a more custom generator instead of Rails generators.
    # We this for more control over the jobs and can add more features.
    # IE: Different event based jobs.
    def run_job_generator
      require "jets/generators/job/job_generator"
      JobGenerator.start(@args, @config)
    end

    def run_rails_generator
      # We lazy require so Rails const is only defined when using generators
      # Using require at the top and configuring do_not_eager_load is not enough.
      # This is because we call require "jets/generators" throughout the codebase.
      require "rails/generators"
      require "rails/configuration"

      # => Jets::Generators.configure! => Rails::Generators.configure!(config)
      self.class.configure!(config)

      # Ultimately, Rails::Generator.invoke is called.
      # Here are some examples to show how args are passed to Rails::Generator.invoke.
      #
      # jets generate kingsman:controllers users -c=sessions
      #     @namespace kingsman:controllers
      #     @args ["users", "-c=sessions"]
      #
      # jets generate scaffold post title:string body:text published:boolean --force
      #     @args ["post", "title:string", "body:text", "published:boolean", "--force"]

      Rails::Generators.invoke(@namespace, @args, @config)
    end

    def config
      config = Jets.application.config.generators
      config.orm :active_record, migration: true, timestamps: true
      config.templates = [jets_templates_path] # add jets_templates_path for customizations
      if Jets.application.config.mode == 'api'
        config.api_only = true
        config.template_engine nil
      else
        config.template_engine :erb
      end
      config
    end

    # Rails and Thor allows overriding the provided templates with source root.
    # The structure is slightly different with source_paths.
    #   source_root  railties-7.0.8/lib/rails/generators/erb/scaffold/templates
    #   source_paths lib/jets/generators/overrides/templates/erb/scaffold
    # See how templates is prefix instead of a suffix.
    #   erb/scaffold/templates
    #   templates/erb/scaffold
    # This is nice because everything is together in the overrides/template folder.
    def jets_templates_path
      File.expand_path("generators/overrides/templates", __dir__)
    end

    class << self
      def configure!(config)
        require "rails/generators"
        Rails::Generators.configure!(config)
      end

      def invoke(generator, args = ARGV, config = {})
        new(generator, args, config).run(:invoke)
      end

      def revoke(generator, args = ARGV, config = {})
        new(generator, args, config).run(:revoke)
      end
    end
  end
end
