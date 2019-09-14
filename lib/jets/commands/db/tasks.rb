class Jets::Commands::Db::Tasks
  # Ugly but it loads ActiveRecord database tasks
  def self.load!
    # Lazy require rails so Rails const is only defined in jets db:* tasks
    require "rails"
    require "active_record"

    # Jets.boot # Jets.boot here screws up jets -h, the db_config doesnt seem to match exactly
    # but seems to be working anyway.
    db_configs = Jets.application.config.database
    ActiveRecord::Tasks::DatabaseTasks.database_configuration = db_configs
    ActiveRecord::Tasks::DatabaseTasks.migrations_paths = ["db/migrate"]
    ActiveRecord::Tasks::DatabaseTasks.seed_loader = Seeder.new("#{Jets.root}/db/seeds.rb")

    # Need to mock out the usage of Rails.application in:
    # activerecord-5.1.4/lib/active_record/tasks/database_tasks.rb
    Rails.application = Dummy::App.new
    load "active_record/railties/databases.rake"
    load File.expand_path("../environment-task.rake", __FILE__)
  end


  # Thanks: https://stackoverflow.com/questions/19206764/how-can-i-load-activerecord-database-tasks-on-a-ruby-project-outside-rails/24840749
  class Seeder
    def initialize(seed_file)
      @seed_file = seed_file
    end

    def load_seed
      raise "Seed file '#{@seed_file}' does not exist" unless File.file?(@seed_file)
      load @seed_file
    end
  end
end
