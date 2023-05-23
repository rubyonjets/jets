require "active_record"

module Jets::Internal
  # Reference: https://github.com/rails/rails/blob/master/actionmailer/lib/action_mailer/railtie.rb
  class Activerecord < ::Jets::Turbine
    config.active_record = ActiveSupport::OrderedOptions.new
    config.active_record.log_queries = false

    rake_tasks do
      namespace :db do
        task :load_config do
          if defined?(ENGINE_ROOT) && engine = Jets::Engine.find(ENGINE_ROOT)
            if engine.paths["db/migrate"].existent
              ActiveRecord::Tasks::DatabaseTasks.migrations_paths += engine.paths["db/migrate"].to_a
            end
          end
        end
      end

      load "active_record/railties/databases.rake"
    end

    initializer "active_record.initialize_database" do
      ActiveSupport.on_load(:active_record) do
        self.configurations = Jets.application.config.database_configuration
        establish_connection
      end
    end

    initializer "active_record.logger" do
      # use STDOUT instead of Jets.logger so we don't have to set Jets.logger.level = :debug
      if config.active_record.log_queries || ENV['JETS_AR_LOG'] || ENV['AR_LOG']
        ActiveSupport.on_load(:active_record) { self.logger = Logger.new(STDOUT) }
      end
    end
  end
end
