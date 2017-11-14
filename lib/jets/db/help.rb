# Though Jets::Db is not a subcommand, organizing the help for it.
class Jets::Db::Help
  class << self
    def db
<<-EOL
Runs ActiveRecord DB tasks.  This delegates to rake db:command1:command2 etc.  So:

jets db create => rake db:migrate

#{db_tasks}
EOL
    end

    def db_tasks
      # Think that Thor calls these desc and in turn methods on boot time.
      # Dont show db tasks help for linux for speed up boot time for Lambda
      reutrn "" if RUBY_PLATFORM =~ /linux/

      out = `bundle exec rake -T`
      tasks = out.split("\n").grep(/db:/)
      commands = tasks.map do |t|
                  # remove comment and rake
                  coloned_task = t.sub('rake ','')
                  spaced_task = coloned_task.gsub(':', ' ')
                  "jets #{spaced_task}"
                end.join("\n\n")

      "The commands:\n\n#{commands}"

      # Cannot figure how to get only the tasks with descirptions using
      # Rake::Task.tasks...

      # Jets::Db::Tasks.load!
      # tasks = Rake::Task.tasks.map(&:name) # ["db:setup", "db:create", ...]

      # tasks.map do |t|
      #   task_with_spaces = t.split(':').join(' ')
      #   "jets #{task_with_spaces}"
      # end.join("\n\n")
    end

    def generate
<<-EOL
Generates migration in db/migrate

Examples:

$ jets db generate create_articles title:string user_id:integer
EOL
    end
  end
end
