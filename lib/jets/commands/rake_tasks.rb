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
      Jets::Booter.require_bundle_gems # use bundler when in project folder

      Jets::Commands::Db::Tasks.load!
      load_webpacker_tasks

      @@loaded = true
    end

    # Handles load errors gracefuly per Booter.required_bundle_gems comments.
    def load_webpacker_tasks
      begin
        require "webpacker"
      rescue LoadError
        # puts "WARN: unable to load gem. #{$!}. Running with 'bundle exec' might fix this warning."
        # Happens whne user calls jets help outside the jets project folder.
        return
      end
      Webpacker::RakeTasks.load!
    end
  end
end
