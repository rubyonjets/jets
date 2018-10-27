class Jets::Commands::Import
  class Rail < Sequence
    def start_message
      puts "Importing Rails app into the rack folder..."
    end

    def create_rack_folder
      repo? ? clone_project : copy_project
    end

    def configure_ruby
      gsub_file 'rack/Gemfile', /^ruby(.*)/, '# ruby\1' # comment out ruby declaration
      create_file "rack/.ruby-version", RUBY_VERSION, force: true
    end

    def bundle_install
      Bundler.with_clean_env do
        run "cd rack && bundle install"
      end
    end

    def configure_routes
      # comment out current catchall route
      comment_lines("config/routes.rb", 'any[ (][\'"]\*', verbose: true) # any "*catchall", to: ...

      # Add catchall route for rack
      insert_into_file "config/routes.rb", :before => /^end/ do
        text = <<-CODE
  # Enables Mega Mode Rails integration
  any "*catchall", to: "jets/rack#process"
CODE
      end
    end

    def create_rackup_wrappers
      path = File.expand_path("../../builders/rackup_wrappers", File.dirname(__FILE__))
      set_source_paths(path) # switch the source path
      directory ".", "#{rack_folder}/bin"
      chmod "#{rack_folder}/bin/rackup", 0755
    end

    def finish_message
      return
      puts <<~EOL
        #{"="*30}
        Congrats! The Rails project from #{@source} has been imported to the rack folder.  Here are some next steps:

        # Local Testing

        Check out the config/routes.rb file and noticed how a new catchall route has been added. The catchall route routes the requests from the jets app to the Rails rack app.  You can selectively route what you want.

        Test the application locally. Test that the Rails app in the rack subfolder works independently.  You can start the application up with:

            cd rack # cd into the imported Rails project
            rackup

        The rack server starts up on http://localhost:9292  You might have to make sure that the database is configured.

        Once tested, stop that server with CTRL-C.

        Then you can start the jets server from the main jets project:

            cd .. # back to the main jets projet
            jets server # starts both jets and rack servers

        The jets server starts up on http://localhost:8888  You can stop both servers with CTRL-C.

        # Deploy

        When you're ready deploy to AWS Lambda with:

            jets deploy
      EOL
    end
  end
end
