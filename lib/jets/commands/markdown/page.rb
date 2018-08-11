module Jets::Commands::Markdown
  class Page
    attr_reader :cli_name
    def initialize(cli_class:, command_name:)
      @cli_class = cli_class # IE: Jets::Commands::Main
      @command_name = command_name # IE: generate

      @cli_name = "jets"
      @command = @cli_class.commands[@command_name]
    end

    def usage
      banner = @cli_class.send(:banner, @command) # banner is protected method
      invoking_command = File.basename($0) # could be rspec, etc
      banner.sub(invoking_command, cli_name)
    end

    def full_command
      [namespace, @command_name].compact.join(':')
    end

    def namespace
      ns = @cli_class.to_s.sub('Jets::Commands::','').underscore.gsub('/','-')
      ns == 'main' ? nil : ns
    end

    def description
      @command.description
    end

    def options
      shell = Shell.new
      @cli_class.send(:class_options_help, shell, nil => @command.options.values)
      text = shell.stdout.string
      return "" if text.empty? # there are no options

      lines = text.split("\n")[1..-1] # remove first line wihth "Options: "
      lines.map! do |line|
        # remove 2 leading spaces
        line.sub(/^  /, '')
      end
      lines.join("\n")
    end

    # Use command's long description as main description
    def long_description
      text = @command.long_description
      return "" if text.nil? # empty description

      lines = text.split("\n")
      lines.map do |line|
        # In the CLI help, we use 2 spaces to designate commands
        # In Markdown we need 4 spaces.
        line.sub(/^  \b/, '    ')
      end.join("\n")
    end

    def path
      full_name = [cli_name, namespace, @command_name].compact.join('-')
      "docs/_reference/#{full_name}.md"
    end

    def doc
      <<-EOL
#{front_matter}
#{usage_markdown}
#{long_desc_markdown}
#{options_markdown}
EOL
    end

    def front_matter
      command = [cli_name, full_command].compact.join(' ')
      <<-EOL
---
title: #{command}
reference: true
---
EOL
    end

    def usage_markdown
      <<-EOL
## Usage

    #{usage}
EOL
    end

    def desc_markdown
      <<-EOL
## Description

#{description}
EOL
    end

    # If the Thor long_description is empty then use the description.
    def long_desc_markdown
      return desc_markdown if long_description.empty?

      <<-EOL
## Description

#{description}.

#{long_description}
EOL
    end

    # handles blank options
    def options_markdown
      return '' if options.empty?

      <<-EOL
## Options

```
#{options}
```
EOL
    end

  end
end
