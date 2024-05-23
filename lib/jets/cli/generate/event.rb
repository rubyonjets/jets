class Jets::CLI::Generate
  class Event < Jets::CLI::Group::Base
    argument :name, required: true, desc: "Event name. Example: cool"

    def self.cli_options
      [
        [:force, aliases: :f, type: :boolean, desc: "Bypass overwrite are you sure prompt for existing files"],
        [:method, aliases: :m, desc: "Method name", default: "handle"],
        [:trigger, aliases: :t, desc: "Event trigger", default: "scheduled"]
      ]
    end
    cli_options.each { |args| class_option(*args) }

    source_root "#{__dir__}/templates/event_types"

    public

    def application_event
      template "application_event.rb", "app/events/application_event.rb", skip: true
    end

    def event
      trigger = options[:trigger]
      trigger = "scheduled" if trigger == "schedule" # allow both to work
      template_path = "#{trigger}.rb.tt"
      template template_path, "app/events/#{underscore_name}_event.rb"
    end
  end
end
