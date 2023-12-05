module Jets::Command
  class GemsCommand < Base
    desc "check", "Check if precompiled Lambda gems are available"
    long_desc Help.text("gems:check")
    option :verbose, type: :boolean, desc: "Verbose mode"
    def check
      Jets.boot
      check = Jets::Api::Gems::Check.new(@options)
      check.run! # exits early if missing gems found
      # If reach here, means all gems are ok.
      puts "Congrats! All gems are available in as precompiled Lambda gems 👍"
    end
  end
end
