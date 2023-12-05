# frozen_string_literal: true

module Jets
  module Command
    class PluginCommand < Base # :nodoc:
      hide_command!

      def help
        run_plugin_generator %w( --help )
      end

      def self.banner(*) # :nodoc:
        "#{executable} new [options]"
      end

      class_option :rc, type: :string, default: File.join("~", ".jetsrc"),
        desc: "Initialize the plugin command with previous defaults. Uses .jetsrc in your home directory by default."

      class_option :no_rc, desc: "Skip evaluating .jetsrc."

      def perform(type = nil, *plugin_args)
        plugin_args << "--help" unless type == "new"

        unless options.key?("no_rc") # Thor's not so indifferent access hash.
          jetsrc = File.expand_path(options[:rc])

          if File.exist?(jetsrc)
            extra_args = File.read(jetsrc).split(/\n+/).flat_map(&:split)
            say "Using #{extra_args.join(" ")} from #{jetsrc}"
            plugin_args.insert(1, *extra_args)
          end
        end

        run_plugin_generator plugin_args
      end

      private
        def run_plugin_generator(plugin_args)
          require "jets/generators"
          require "jets/generators/jets/plugin/plugin_generator"
          Jets::Generators::PluginGenerator.start plugin_args
        end
    end
  end
end
