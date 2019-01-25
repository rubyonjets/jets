class Jets::Turbo
  class DatabaseYaml
    def reconfigure
      current_yaml = "#{Jets.root}/rack/config/database.yml"
      return unless File.exist?(current_yaml)

      vars = {}
      current_database = YAML.load_file(current_yaml)
      database_names = infer_database_name(current_database)
      vars.merge!(database_names)
      vars['adapter'] = current_database['development']['adapter']

      path = File.expand_path("templates/config/database.yml", File.dirname(__FILE__))
      content = Jets::Erb.result(path, vars)
      IO.write(current_yaml, content)
      # puts "Reconfigured #{current_yaml}" # uncomment to inspect and debug
    rescue Exception => e
      puts "WARNING: Was not able to generate a database.yml. Leaving your current one in place"
      puts e.message
      # If unable to copy the database.yml settings just slightly fail.
      # Do this because really unsure what is in the current database.yml
    end

    def infer_database_name(current_database)
      vars = {}
      %w[development test production].each do |env|
        if !current_database[env]['database'].include?('<%') # already has ERB
          vars["database_#{env}"] = current_database[env]['database']
        else
          lines = IO.readlines("#{Jets.root}/rack/config/application.rb")
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
