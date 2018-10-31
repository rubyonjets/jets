module Jets::Commands
  class Gems < Jets::Commands::Base
    desc "check", "Check pre-built Lambda gems are available from the sources"
    long_desc Help.text(:check)
    def check
      check = Jets::Gems::Check.new(use_gemspecs: true)
      check.run
      if check.missing?
        puts check.missing_message
        Jets::Gems::Report.missing(check.missing_gems)
      else
        puts "All gems are available in as pre-built Lambda gems 👍"
      end
    end
  end
end
