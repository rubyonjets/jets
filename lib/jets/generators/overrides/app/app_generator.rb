require "rails/generators"
require "rails/generators/rails/app/app_generator"

module Jets::Generators::Overrides::App
  # Allows overriding generator creation of the Gemfile, README, etc.
  # See: Rails::AppBuilder for the full list of overridable methods.
  class AppBuilder < Rails::AppBuilder
  end

  module AppBaseOverrides
    extend ActiveSupport::Concern
    DATABASES = Rails::Generators::Database::DATABASES
    VALID_MODES = %w[html api job]

    module ClassMethods
      # Override to support jets options only
      def add_shared_options_for(name)
        class_option :name,     type: :string, aliases: "-n",
                                desc: "Name of the app"

        class_option :template, type: :string, aliases: "-m",
                                desc: "Path to some #{name} template (can be a filesystem path or URL)"

        class_option :database, type: :string, aliases: "-d", default: "mysql",
                                desc: "Preconfigure for selected database (options: #{DATABASES.join('/')})"

        class_option :mode, default: 'html',
                            desc: "mode: #{VALID_MODES.join(',')}"

        class_option :javascript, type: :string, aliases: "-j", default: "importmap",
                                  desc: "Choose JavaScript approach [options: importmap (default)]"

      end

      # Prepend jets_template_path to source_paths so that the jets templates
      # can override the rails templates.
      def source_paths
        rails_templates_path = Rails::Generators::AppGenerator.source_root
        [jets_templates_path, rails_templates_path] + super
      end

      def jets_templates_path
        File.join(jets_generator_root, "templates")
      end

      def jets_generator_root
        File.expand_path(__dir__)
      end

      def banner # :doc:
        "jets new #{arguments.map(&:usage).join(' ')} [options]"
      end

      def usage_path
        path = File.join(jets_generator_root, "USAGE")
        if File.exist?(path)
          path
        else
          super
        end
      end

      # We want to exit on failure to be kind to other libraries
      # This is only when accessing via CLI
      def exit_on_failure?
        true
      end
    end
  end

  class AppGenerator < Rails::Generators::AppBase
    include AppBaseOverrides
    include Helpers

    add_shared_options_for "application"

    public_task :set_default_accessors!
    public_task :create_root
    # public_task :target_rails_prerelease

    # The Rails way generates a project piecemeal like so:
    #
    #   def create_root_files
    #     build(:readme)
    #     build(:rakefile)
    #   end
    #
    # The Jets way generates the entire project at once.
    #
    # We first create the entire project at once because it's easier to maintain.
    # But we can also use the Rails way to generate piecemeal and leverage
    # the existing Rails generators.

    public_task :set_initial_variables
    public_task :copy_project # Note: Support for clone has been removed

    def create_root_files
      build(:version_control)
    end

    def create_bin_files
      build(:bin)
    end

    # def create_active_record_files
    #   return if options[:skip_active_record]
    #   build(:database_yml)
    # end

    public_task :run_bundle

    # Custom version because Rails run_javascript calls rails importmap:install
    def run_javascript
      return unless options[:mode] == "html"

      if options[:javascript] == "importmap"
        sh "bundle exec jets importmap:install"
      else
        puts "WARN: Only importmap is supported at this time."
      end
    end

    public_task :git_first_commit

  private
    def gemfile_entries # :doc:
      if options[:database].nil? # --no-database
        return []
      end

      [
        database_gemfile_entry,
      ].flatten.compact.select(&@gem_filter)
    end

  def sh(command)
      puts "=> #{command}"
      system(command)
    end

    def get_builder_class
      AppBuilder
    end
  end
end

# Keeps zeitwerk happy
Jets::Generators::AppGenerator = Jets::Generators::Overrides::App::AppGenerator
