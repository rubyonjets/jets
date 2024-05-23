class Jets::CLI::Maintenance
  class Worker < Base
    def on
      check_workers!

      if on?
        warn "Worker maintenance is already on"
      else
        Saver.new(@options).save_concurrency_settings
        Zeroer.new(@options).zero_all_concurrency
        warn "Worker maintenance has been turned on"
      end
    end

    def off
      check_workers!

      if on?
        Restorer.new(@options).restore_concurrency_settings
        warn "Worker maintenance has been turned off"
      else
        warn "Worker maintenance is already off"
      end
    end

    def on?
      check_workers!
      Zeroer.new(@options).all_zeroed?
    end
  end
end
