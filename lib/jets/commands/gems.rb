module Jets::Commands
  class Gems < Jets::Commands::Base
    desc "check", "Check if pre-built Lambda gems are available from the sources"
    long_desc Help.text("gems:check")
    def check
      check = Jets::Gems::Check.new(cli: true)
      check.run
      if check.missing?
        puts check.missing_message
        Jets::Gems::Report.missing(check.missing_gems)
      else
        puts "Congrats! All gems are available in as pre-built Lambda gems 👍"
      end
    end
    
    desc "sources", "List configured sources", hide: true
    long_desc Help.text("gems:sources")
    def sources
      puts "Your pre-built lambda gem sources are:"
      Jets.config.gems.sources.each do |source|
        puts "  #{source}"
      end
    end
  end
end
