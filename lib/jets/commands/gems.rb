module Jets::Commands
  class Gems < Jets::Commands::Base
    desc "check", "Check if pre-built Lambda gems are available from the sources"
    long_desc Help.text("gems:check")
    def check
      check = Jets::Gems::Check.new
      check.run! # exits early if missing gems found
      # If reach here, means all gems are ok.
      puts "Congrats! All gems are available in as pre-built Lambda gems 👍"
    end

    desc "sources", "List pre-built Lambda gem sources"
    long_desc Help.text("gems:sources")
    def sources
      puts "Your pre-built Lambda gem sources are:"
      Jets.config.gems.sources.each do |source|
        puts "  #{source}"
      end
    end
  end
end
