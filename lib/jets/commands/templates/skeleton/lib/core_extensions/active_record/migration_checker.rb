module CoreExtensions
  module ActiveRecord
    module MigrationChecker
      def prepare_test_db
        require 'rails'

        current_config = ::ActiveRecord::Base.connection_config
        all_configs = ::ActiveRecord::Base.configurations.configs_for(env_name: Jets.env)

        needs_update = !all_configs.all? do |db_config|
          # Need to mock out the usage of Rails.application in:
          # activerecord-6.0.0/lib/active_record/tasks/database_tasks.rb
          Rails.application = Jets::Commands::Db::Tasks::Dummy::App.new
          ::ActiveRecord::Tasks::DatabaseTasks.schema_up_to_date?(db_config.config, ::ActiveRecord::Base.schema_format, nil, Jets.env, db_config.spec_name)
        end

        if needs_update
          # Roundtrip to Rake to allow plugins to hook into database initialization.
          FileUtils.cd(Jets.root) do
            ::ActiveRecord::Base.clear_all_connections!
            system("jets db:test:prepare")
          end
        end

        # Establish a new connection, the old database may be gone (db:test:prepare uses purge)
        ::ActiveRecord::Base.establish_connection(current_config)

        begin
          check_pending!
        rescue ::ActiveRecord::PendingMigrationError
          puts "Migrations are pending. To resolve this issue, run:\n\n        jets db:migrate"
          exit 1
        end
      end
    end
  end
end
