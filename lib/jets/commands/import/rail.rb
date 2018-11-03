class Jets::Commands::Import
  class Rail < Base
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
      current_yaml = "#{Jets.root}rack/config/database.yml"
      return unless File.exist?(current_yaml)

      vars = {}
      current_database = YAML.load_file(current_yaml)
      database_names = infer_database_name(current_database)
      vars.merge!(database_names)
      vars['adapter'] = current_database['development']['adapter']

      path = File.expand_path("templates/config/database.yml", File.dirname(__FILE__))
      content = Jets::Erb.result(path, vars)
      IO.write(current_yaml, content)
      puts "Reconfigured #{current_yaml}"
    rescue Exception
      # If unable to copy the database.yml settings just slightly fail.
      # Do this because really unsure what is in the current database.yml
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

  private
    def infer_database_name(current_database)
      vars = {}
      %w[development test production].each do |env|
        if !current_database[env]['database'].include?('<%') # already has ERB
          vars["database_#{env}"] = current_database[env]['database']
        else
          lines = IO.readlines("#{Jets.root}rack/config/application.rb")
          module_line = lines.find { |l| l =~ /^module / }
          app_module = module_line.gsub(/^module /,'').strip
          app_name = app_module.underscore
          vars["database_#{env}"] = "#{app_name}_#{env}"
        end
      end

      vars
    end
  end
end
