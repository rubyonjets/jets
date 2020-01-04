require 'rake'

class Jets::Commands::RakeTasks
  class << self
    # Will only load the tasks once.  Just in case the user has already loaded
    # Jets rake tasks in their Rakefile. Example Rakefile that does this:
    #
    #   require 'jets'
    #   Jets.load_tasks
    #
    @@loaded = false
    def load!
      return if @@loaded # prevent loading twice
      # Run Bundler.setup so all project rake tasks also show up in `jets help`
      Jets::Bundle.setup

      Jets::Commands::Db::Tasks.load!
      load_webpacker_tasks

      # custom project rake tasks
      Dir.glob("#{Jets.root}/lib/tasks/*.rake").each { |r| load r }

      @@loaded = true
    end

    # Handles load errors gracefuly per Booter.required_bundle_gems comments.
    def load_webpacker_tasks
      begin
        require "webpacker"
        require "webpacker/rake_tasks"
      rescue LoadError
        # puts "WARN: unable to load gem. #{$!}. Running with 'bundle exec' might fix this warning."
        # Happens whne user calls jets help outside the jets project folder.
        return
      end

      Webpacker::RakeTasks.load!
      # Thanks: https://coderwall.com/p/qhdhgw/adding-a-post-execution-hook-to-the-rails-db-migrate-task
      # Enchancing in case the user runs webpacker:install afterwards
      # instead of jets new.
      Rake::Task['webpacker:install'].enhance do
        # FORCE from rake webpacker:install FORCE=1
        # using ENV because rake webpacker:install is a rake task
        args ||= []
        args += ["--force"] if ENV['FORCE']
        Jets::Commands::WebpackerTemplate.start(args)
      end
    end
  end
end
