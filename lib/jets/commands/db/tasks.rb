require "rails"
require "active_record"
require "recursive-open-struct"

class Jets::Commands::Db::Tasks
  # Ugly but it loads ActiveRecord database tasks
  def self.load!
    database_yml = "#{Jets.root}config/database.yml"
    return unless File.exist?(database_yml)

    text = ERB.new(IO.read(database_yml)).result
    config = YAML.load(text)
    ActiveRecord::Tasks::DatabaseTasks.database_configuration = config
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
