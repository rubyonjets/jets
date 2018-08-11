module Jets::Commands::Markdown
  class Creator
    cattr_accessor :mute

    def self.create_all
      clean
      new.create_all
    end

    def self.clean
      FileUtils.rm_rf("docs/_reference")
      FileUtils.rm_f("docs/reference.md")
    end

    def cli_classes
      Jets::Commands::Base.namespaced_commands.map do |full_command|
        # IE of full_command: dynamodb:generate
        Jets::CLI.new([full_command]).lookup(full_command)
      end.uniq
    end

    def create_all
      create_index

      cli_classes.each do |cli_class|
        # cli_class examples:
        #   Jets::Commands::Main
        #   Jets::Commands::Db
        #   Jets::Commands::Dynamodb::Migrate
        cli_class.commands.each do |command|
          command_name = command.first

          page = Page.new(cli_class: cli_class, command_name: command_name)
          create_page(page)
        end
      end
    end

    def create_page(page)
      puts "Creating page: #{page.path}..."
      FileUtils.mkdir_p(File.dirname(page.path))
      IO.write(page.path, page.doc)
    end

    def create_index
      create_include_reference
      page = Index.new
      FileUtils.mkdir_p(File.dirname(page.path))
      puts "Creating index: #{page.path}"
      IO.write(page.path, page.doc)
    end

    def create_include_reference
      path = "docs/_includes/reference.md"
      IO.write(path, "Generic tool description. Please edit #{path} with a description.") unless File.exist?(path)
    end
  end
end