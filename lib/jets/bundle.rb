module Jets
  # Named Bundle vs Bundler to avoid having to fully qualify ::Bundler
  module Bundle
    # Looks like for zeitwerk module autovivification to work `bundle exec` must be called.
    # This allows zeitwork module autovivification to work even if the user has not called jets with `bundle exec jets`.
    # Bundler.setup is essentially the same as `bundle exec`
    # Reference: https://www.justinweiss.com/articles/what-are-the-differences-between-irb/
    #
    # The Bundler.setup is only necessary because we use Bundler.require after require "zeitwerk" is called.
    #
    # Note, this is called super early right before require "zeitwerk"
    # The initially Bundler.setup does not include the Jets.env group.
    # Later in Jets::Core::Booter, Bundle.require is called and includes the Jets.env group.
    #
    def setup
      return unless jets_project?
      return unless gemfile?
      Kernel.require "bundler/setup"
      Bundler.setup # Same as Bundler.setup(:default)
    rescue LoadError => e
      handle_error(e)
    end

    # Bundler.require called when environment boots up via Jets.boot.  This will eagerly require all gems in the
    # Gemfile. This means the user will not have to explictly require dependencies.
    #
    # It also useful for when to loading Rake tasks in Jets::Thor::RakeTasks.load! For example, some gems like
    # webpacker that load rake tasks are specified with a git based source:
    #
    #   gem "webpacker", git: "https://github.com/tongueroo/webpacker.git"
    #
    # This results in the user having to specific bundle exec in front of jets for those rake tasks to show up in
    # jets help. Instead, when the user is within the project folder, jets automatically requires bundler for the
    # user. So the rake tasks show up when calling jets help.
    #
    # When the user calls jets help from outside the project folder, bundler is not used and the load errors get
    # rescued gracefully.  This is done in Jets::Thor::RakeTasks.load!  In the case when user is in another
    # project with another Gemfile, the load errors will also be rescued.
    def require
      return unless jets_project?
      return unless gemfile?
      Kernel.require "bundler/setup"
      Bundler.require(*bundler_groups)
    rescue LoadError => e
      handle_error(e)
    end

    def handle_error(e)
      puts e.message
      puts <<~EOL.color(:yellow)
        WARNING: Unable to require "bundler/setup"
        There may be something funny with your ruby and bundler setup.
        You can try upgrading bundler and rubygems:

            gem install --default bundler
            gem update --system
            bundle update --bundler

        Here are some links that may be helpful:

        * https://bundler.io/blog/2019/01/03/announcing-bundler-2.html
        * https://community.boltops.com/t/jets-1-9-8-issue-cannot-load-such-file-bundler-setup-loaderror/185/2
        * https://community.boltops.com/t/could-not-find-timeout-0-3-1-in-any-of-the-sources/996

        Also, running bundle exec in front of your command may remove this message.
      EOL
    end

    def gemfile?
      ENV["BUNDLE_GEMFILE"] || File.exist?("Gemfile")
    end

    def bundler_groups
      [:default, Jets.env.to_sym]
    end

    def jets_project?
      File.exist?("config/jets")
    end

    extend self
  end
end
