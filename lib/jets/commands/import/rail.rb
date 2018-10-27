class Jets::Commands::Import
  class Rail < Sequence
    def message
      puts "Importing Rails app into the rack folder..."
    end

    def configure_ruby
      gsub_file 'rack/Gemfile', /^ruby(.*)/, '# ruby\1' # comment out ruby declaration
      create_file "rack/.ruby-version", Jets::RUBY_VERSION, force: true
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
  end
end
