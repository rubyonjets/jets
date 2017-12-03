require "rails"
require "active_record"
require "recursive-open-struct"

class Jets::Commands::Db::Tasks
  # Ugly but it loads ActiveRecord database tasks
  def self.load!
    db_configs = Jets.application.config.database.to_h.deep_stringify_keys
    ActiveRecord::Tasks::DatabaseTasks.database_configuration = db_configs
    ActiveRecord::Tasks::DatabaseTasks.migrations_paths = ["db/migrate"]

    # Need to mock out the usage of Rails.application in:
    # activerecord-5.1.4/lib/active_record/tasks/database_tasks.rb
    Rails.application = RecursiveOpenStruct.new(
      config: {
        paths: {
          db: ["db"],
        }
      },
      paths: {
        "db/migrate": ["db/migrate"]
      }
    )
    load "active_record/railties/databases.rake"

    load File.expand_path("../environment-task.rake", __FILE__)
  end
end
