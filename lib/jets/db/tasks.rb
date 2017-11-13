require "rails"
require "active_record"

class Jets::Db::Tasks
  def self.load!
    text = ERB.new(IO.read("#{Jets.root}config/database.yml")).result
    config = YAML.load(text)
    ActiveRecord::Tasks::DatabaseTasks.database_configuration = config
    ActiveRecord::Tasks::DatabaseTasks.migrations_paths = ["db/migrate"]
    load "active_record/railties/databases.rake"
    load File.expand_path("../environment-task.rake", __FILE__)
  end
end
