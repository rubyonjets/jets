class Jets::Commands::Import
  class Rails < Base
    # We add jets-rails gem even though it's only activated within the megamode
    # rackup wrapper script so user can check run bundle install and determine early
    # if dependencies are met. The jets-rails gem is also added as part of the deploy
    # process but we add it here also so the user gets earlier possible errors and
    # can fix before they hit the deploy phase.
    def configure_gemfile
      append_to_file 'rack/Gemfile' do
        %Q|gem "jets-rails"\n|
      end
    end

    def install
      bundle_install
    end

    def configure_routes
      # comment out current catchall route
      comment_lines("config/routes.rb", 'any[ (][\'"]\*', verbose: true) # any "*catchall", to: ...

      # Add catchall route for rack
      insert_into_file "config/routes.rb", :before => /^end/ do
        <<-CODE
  # Enables Mega Mode Rails integration
  any "*catchall", to: "jets/rack#process"
CODE
      end
    end

    def reconfigure_database_yml
      Jets::Turbo::DatabaseYaml.new.reconfigure
    end

    def finish_message
      puts <<~EOL
        #{"="*30}
        Congrats! The Rails project from #{@source} has been imported to the rack folder.  Here are some next steps:

        # Local Testing

        Check out the config/routes.rb file and noticed how a new catchall route has been added.  It looks something like this:

            any "*catchall", to: "jets/rack#process"

        The catchall route passes any route not handled by the Jets app as a request onto the Rails app.  You can modified the route to selectively route what you want.

        Please double check that rack/config/database.yml is appropriately configured, it likely needs to be updated.

        Test the application locally. Test that the Rails app in the rack subfolder works independently.  You can start the application up with:

            cd rack # cd into the imported Rails project
            bundle exec rackup

        The rack server starts up on http://localhost:9292

        Once tested, stop that server with CTRL-C.

        Then you can start the jets server from the main jets project:

            cd .. # back to the main jets projet
            jets server # starts both jets and rack servers

        The jets server starts up on http://localhost:8888  You can stop both servers with CTRL-C.

        # Deploy

        When you are ready deploy to AWS Lambda with:

            jets deploy
        EOL
    end
  end
end
