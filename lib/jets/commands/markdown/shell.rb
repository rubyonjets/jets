require 'thor'

module Jets::Commands::Markdown
  # Override stdout as an @io object so we can grab the text written normally
  # outputted to the shell.
  class Shell < Thor::Shell::Basic
    def stdout
      @io ||= StringIO.new
    end
  end
end
