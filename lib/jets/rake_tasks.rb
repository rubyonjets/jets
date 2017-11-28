class Jets::RakeTasks
  class << self
    # Will only load the tasks once.  Just in case the user has already loaded
    # Jets rake tasks in their Rakefile. Example Rakefile that does this:
    #
    #   require 'jets'
    #   Jets::RakeTasks.load!
    #
    @@loaded = false
    def load!
      return if @@loaded # prevent loading twice

      Jets::Booter.require_bundle_gems # forucing use of bundler in case
        # there are gems in the Gemile that use a git gem source.  Example:
        #  gem "webpacker", git: "git@github.com:tongueroo/webpacker.git"

      Jets::Commands::Db::Tasks.load!
      load_webpacker_tasks
      @@loaded = true
    end

    def load_webpacker_tasks
      begin
        require "webpacker"
      rescue LoadError
        # puts "WARN: unable to load gem. #{$!}. Running with 'bundle exec' might fix this warning."

        # Can happen if the user calls jets not in a folder with the right Gemfile
        # or in a folder without Gemfile at all.
        return
      end
      Webpacker::RakeTasks.load!
    end
  end
end
