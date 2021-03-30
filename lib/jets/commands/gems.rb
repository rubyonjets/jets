module Jets::Commands
  class Gems < Jets::Commands::Base
    desc "check", "Check if pre-built Lambda gems are available from the sources"
    long_desc Help.text("gems:check")
    option :show_source, type: :boolean, desc: "Show source"
    def check
      check = Jets::Gems::Check.new(@options)
      check.run! # exits early if missing gems found
      # If reach here, means all gems are ok.
      puts "Congrats! All gems are available in as pre-built Lambda gems 👍"
    end
  end
end
