class Jets::CLI
  class Generate < Jets::Thor::Base
    Event.cli_options.each { |args| option(*args) }
    register(Event, "event", "event NAME", "Generate event app code")
  end
end
