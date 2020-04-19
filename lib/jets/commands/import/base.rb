class Jets::Commands::Import
  class Base < Sequence
    # Ugly, but when the class_option is only defined in the Thor::Group class
    # it doesnt show up with jets new help :(
    # If anyone knows how to fix this let me know.
    def self.cli_options
      [
        [:submodule, type: :boolean, default: false, desc: "Imports the project as a submodule"],
      ]
    end
    cli_options.each { |args| class_option(*args) }

    # Since setup is public it will automatically run in the subclasses
    def setup
      start_message
      create_rack_folder
      configure_ruby
      create_rackup_wrappers
    end

  private
    def start_message
      puts "Importing app into the rack folder..."
    end

    def create_rack_folder
      repo? ? clone_project : copy_project
    end

    def configure_ruby
      gsub_file 'rack/Gemfile', /^ruby(.*)/, '# ruby\1' # comment out ruby declaration
      create_file "rack/.ruby-version", RUBY_VERSION, force: true
    end

    def create_rackup_wrappers
      path = File.expand_path("../../builders/rackup_wrappers", File.dirname(__FILE__))
      Dir.glob("#{path}/*").each do |p|
        FileUtils.cp(p, "#{rack_folder}/bin/")
      end
      chmod "#{rack_folder}/bin/rackup", 0755
    end

    def bundle_install
      Bundler.with_unbundled_env do
        run "cd rack && bundle install"
      end
    end
  end
end
