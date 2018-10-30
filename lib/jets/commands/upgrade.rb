module Jets::Commands
  class Upgrade < Jets::Commands::Base
    autoload :V1, "jets/commands/upgrade/v1"

    desc "v1", "Upgrades application to version 1"
    long_desc Help.text('upgrade:v1')
    def v1
      V1.new(options).run
    end
  end
end
