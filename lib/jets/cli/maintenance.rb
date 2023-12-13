class Jets::CLI
  class Maintenance < Jets::Thor::Base
    class_option :role, aliases: [:r], default: "web", desc: "Role to apply the maintenance mode to. IE: web worker"

    desc "on", "Turn on maintenance mode"
    long_desc Help.text("maintenance/on")
    yes_option
    def on
      Mode.new(options).on
    end

    # Note: --yes or -y is not used for the off command.
    # User will not be prompted for confirmation.
    # The option is allowed in case users accidentally use it.
    # Example:
    #   jets maintenance off -y
    # This is why the option is hidden. This makes the user experience better.
    desc "off", "Turn off maintenance mode"
    long_desc Help.text("maintenance/off")
    option :yes, aliases: [:y], type: :boolean, desc: "Skip are you sure prompt", hide: true
    def off
      Mode.new(options).off
    end

    desc "status", "Show maintenance mode status"
    long_desc Help.text("maintenance/status")
    option :all, aliases: [:a], type: :boolean, desc: "Show status for all roles. Takes precedence over --role option", default: false
    def status
      Mode.new(options).status
    end
  end
end
